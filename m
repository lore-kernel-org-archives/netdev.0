From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: network traffic stop with 2.6.29 after ftp put
Date: Tue, 24 Mar 2009 12:30:21 +0100
Message-ID: <BAY103-DAV11986CBE87674225EDC31EB2930@phx.gbl>
References: <BAY103-DAV683AFCEC466B8F2E6D8EBB2930@phx.gbl> <BAY103-DAV100CC8DA92566937097718B2930@phx.gbl> <49C8C26B.7070802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s8.bay0.hotmail.com ([65.54.246.80]:12693 "EHLO
	bay0-omc1-s8.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756664AbZCXLa7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 07:30:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Could you please send us :

just an update: this bug is not related to
ftp: it appears to me that after some
traffic (imap, http) linux stop receiving
any packets.

> iptables -nvL

there isn't any iptables rules
(there isn't even the iptables package
installed on my box)
 
> netstat -s

Ip:
    4808 total packets received
    28 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    4685 incoming packets delivered
    1226 requests sent out
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    68 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 47
        echo request: 21
IcmpMsg:
        OutType3: 47
        OutType8: 21
Tcp:
    21 active connections openings
    0 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    1490 segments received
    1104 segments send out
    30 segments retransmited
    0 bad segments received.
    9 resets sent
Udp:
    4 packets received
    0 packets to unknown port received.
    0 packet receive errors
    24 packets sent
UdpLite:
TcpExt:
    10 TCP sockets finished time wait in fast timer
    27 delayed acks sent
    1240 packet headers predicted
    58 acknowledgments not containing data payload received
    5 predicted acknowledgments
    1 congestion windows recovered without slow start after partial ack
    5 other TCP timeouts
    4 connections aborted due to timeout
IpExt:
    InBcastPkts: 3191


> cat /proc/slabinfo

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
isofs_inode_cache      0      0    320   12    1 : tunables    0    0    0 : slabdata      0      0      0
fat_inode_cache       23     23    344   23    2 : tunables    0    0    0 : slabdata      1      1      0
fat_cache            170    170     24  170    1 : tunables    0    0    0 : slabdata      1      1      0
sgpool-128            12     12   2560   12    8 : tunables    0    0    0 : slabdata      1      1      0
sgpool-64             12     12   1280   12    4 : tunables    0    0    0 : slabdata      1      1      0
sgpool-32             12     12    640   12    2 : tunables    0    0    0 : slabdata      1      1      0
sgpool-16             12     12    320   12    1 : tunables    0    0    0 : slabdata      1      1      0
flow_cache             0      0     80   51    1 : tunables    0    0    0 : slabdata      0      0      0
ext2_inode_cache    8700   8700    408   10    1 : tunables    0    0    0 : slabdata    870    870      0
kiocb                 25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
shmem_inode_cache     10     10    384   10    1 : tunables    0    0    0 : slabdata      1      1      0
posix_timers_cache      0      0    104   39    1 : tunables    0    0    0 : slabdata      0      0      0
UNIX                 108    120    384   10    1 : tunables    0    0    0 : slabdata     12     12      0
UDP-Lite               0      0    480    8    1 : tunables    0    0    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    288   14    1 : tunables    0    0    0 : slabdata      0      0      0
RAW                    9      9    448    9    1 : tunables    0    0    0 : slabdata      1      1      0
UDP                    8      8    480    8    1 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   15     15   1056   15    4 : tunables    0    0    0 : slabdata      1      1      0
blkdev_queue          25     26   1200   13    4 : tunables    0    0    0 : slabdata      2      2      0
blkdev_requests       38     54    216   18    1 : tunables    0    0    0 : slabdata      3      3      0
biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1536   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    768   10    2 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache     124    132    352   11    1 : tunables    0    0    0 : slabdata     12     12      0
skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
file_lock_cache       39     39    104   39    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Operand         675    714     40  102    1 : tunables    0    0    0 : slabdata      7      7      0
Acpi-Namespace       510    510     24  170    1 : tunables    0    0    0 : slabdata      3      3      0
proc_inode_cache     130    130    312   13    1 : tunables    0    0    0 : slabdata     10     10      0
sigqueue              28     28    144   28    1 : tunables    0    0    0 : slabdata      1      1      0
radix_tree_node     3626   3640    296   13    1 : tunables    0    0    0 : slabdata    280    280      0
bdev_cache            19     19    416   19    2 : tunables    0    0    0 : slabdata      1      1      0
sysfs_dir_cache     5864   5865     48   85    1 : tunables    0    0    0 : slabdata     69     69      0
inode_cache          113    126    288   14    1 : tunables    0    0    0 : slabdata      9      9      0
dentry             13469  13472    128   32    1 : tunables    0    0    0 : slabdata    421    421      0
buffer_head        13067  13067     56   73    1 : tunables    0    0    0 : slabdata    179    179      0
vm_area_struct      3893   4462     88   46    1 : tunables    0    0    0 : slabdata     97     97      0
mm_struct             54     57    416   19    2 : tunables    0    0    0 : slabdata      3      3      0
signal_cache          60     64    480    8    1 : tunables    0    0    0 : slabdata      8      8      0
sighand_cache         65     72   1312   12    4 : tunables    0    0    0 : slabdata      6      6      0
task_struct           67     90    800   10    2 : tunables    0    0    0 : slabdata      9      9      0
anon_vma             951   1280     16  256    1 : tunables    0    0    0 : slabdata      5      5      0
idr_layer_cache      177    182    152   26    1 : tunables    0    0    0 : slabdata      7      7      0
kmalloc-4096          17     24   4096    8    8 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-2048         126    136   2048    8    4 : tunables    0    0    0 : slabdata     17     17      0
kmalloc-1024         178    192   1024    8    2 : tunables    0    0    0 : slabdata     24     24      0
kmalloc-512         1134   1152    512    8    1 : tunables    0    0    0 : slabdata    144    144      0
kmalloc-256          175    208    256   16    1 : tunables    0    0    0 : slabdata     13     13      0
kmalloc-128         1171   1344    128   32    1 : tunables    0    0    0 : slabdata     42     42      0
kmalloc-64          2011   2048     64   64    1 : tunables    0    0    0 : slabdata     32     32      0
kmalloc-32           974   1024     32  128    1 : tunables    0    0    0 : slabdata      8      8      0
kmalloc-16          1249   1280     16  256    1 : tunables    0    0    0 : slabdata      5      5      0
kmalloc-8           2400   2560      8  512    1 : tunables    0    0    0 : slabdata      5      5      0
kmalloc-192         1222   1260    192   21    1 : tunables    0    0    0 : slabdata     60     60      0
kmalloc-96           398    630     96   42    1 : tunables    0    0    0 : slabdata     15     15      0

