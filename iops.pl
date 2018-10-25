#!/usr/bin/perl

use strict;

use constant {
    DEV_MAJ             => 0,
    DEV_MIN             => 1,
    DEV_NAME            => 2,
    READS               => 3,
    READS_MERGED        => 4,
    SECTS_READ          => 5,
    TIME_READ           => 6,
    WRITES              => 7,
    WRITES_MERGED       => 8,
    SECTORS_WRITTEN     => 9,
    TIME_WRITE          => 10,
    IOS_IN_PROGRESS     => 11,
    TIME_IO             => 12,
    TIME_IO_WEIGHTED    => 13
};

sub get_devstat {
    my $devname = shift;
    open(my $fh, '<', '/proc/diskstats');
    my @devstat;
    while(<$fh>) {
        s/^\s+|\s+\n$//g;
        @devstat = split /\s+/;
        goto FOUND if $devstat[DEV_NAME] eq $devname;
    }
    die "device not found";
FOUND:
    close($fh);
    return \@devstat;
}

my $devname = $ARGV[0];
die "Please specify device" if not $devname;

my $old_devstat = get_devstat($devname);

while() {
    sleep(1);
    my $new_devstat = get_devstat($devname);
    printf("%s: %4d reads/s, %4d writes/s, %4d pending, %4d%% load\n",
        $new_devstat->[DEV_NAME],
        $new_devstat->[READS] - $old_devstat->[READS],
        $new_devstat->[WRITES] - $old_devstat->[WRITES],
        $new_devstat->[IOS_IN_PROGRESS],
        ($new_devstat->[TIME_IO] - $old_devstat->[TIME_IO]) / 10
    );
    $old_devstat = $new_devstat;
}
