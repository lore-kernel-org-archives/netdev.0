From: Dominique Blas <ml@blas.net>
Subject: Re: [Openswan dev] IPComp
Date: Sat, 3 Jul 2004 13:45:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407031345.10313@db>
References: <Pine.LNX.4.44.0407031301460.27704-100000@expansionpack.xtdnet.nl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Gxp5AgcDKWYXuES"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "D. Hugh Redelmeier" <hugh@mimosa.com>, <dev@lists.openswan.org>,
        <jmorris@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Wouters <paul@xelerance.com>
In-Reply-To: <Pine.LNX.4.44.0407031301460.27704-100000@expansionpack.xtdnet.nl>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_Gxp5AgcDKWYXuES
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Le samedi 3 Juillet 2004 13:02, Paul Wouters a =E9crit :
(...)

> 2.6.5=20
>=20
> He seems to have generic memory problems though, so I don't think this =
is an=20
> openswan or kernel ipsec bug.
No it doesn't seem to be an openswan or kernel ipsec bug.=20

Did you all read my mail from this night (0254 am) ?
i explained there that It seems that openswan suffers under poor memory c=
onditions whereas when there is plenty of memory everything works=20
fine.
I confirm that under these poor memory conditions, using compress=3Dyes l=
imits the return packets ( SFS -> OS2) to 348 bytes whereas with compress=
=3Dno there is no such limitation
(but faled memory allocations in this case but not always).
>=20
> Paul

Please find in attachment the slabinfo with compress and the slabinfo wit=
hout compress tag in ipsec.conf.


Rgds,

db

--Boundary-00=_Gxp5AgcDKWYXuES
Content-Type: text/plain;
  charset="iso-8859-1";
  name="slabinfo.wcompress"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="slabinfo.wcompress"

slabinfo - version: 2.0
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ip_fib_hash           32    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
clip_arp_cache         0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
fib6_nodes             9    112     32  112    1 : tunables  120   60    0 : slabdata      1      1      0
ip6_dst_cache         13     30    256   15    1 : tunables  120   60    0 : slabdata      2      2      0
ndisc_cache            1     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
raw6_sock              0      0    640    6    1 : tunables   54   27    0 : slabdata      0      0      0
udp6_sock              2      6    640    6    1 : tunables   54   27    0 : slabdata      1      1      0
tcp6_sock              5      7   1152    7    2 : tunables   24   12    0 : slabdata      1      1      0
unix_sock              6     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
ip_vs_conn             0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
ip_conntrack        1206   2060    384   10    1 : tunables   54   27    0 : slabdata    206    206      0
ip_mrt_cache           0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
tcp_tw_bucket          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
tcp_bind_bucket        1    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
tcp_open_request       0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
inet_peer_cache       71    116     64   58    1 : tunables  120   60    0 : slabdata      2      2      0
secpath_cache         16     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
xfrm_dst_cache        10     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
ip_dst_cache        4633   4660    384   10    1 : tunables   54   27    0 : slabdata    466    466      0
arp_cache             23     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
raw4_sock              0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
udp_sock              16     21    512    7    1 : tunables   54   27    0 : slabdata      3      3      0
tcp_sock               2      4   1024    4    1 : tunables   54   27    0 : slabdata      1      1      0
flow_cache           534    870    128   30    1 : tunables  120   60    0 : slabdata     29     29      0
hpsb_packet            0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
udf_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
romfs_inode_cache      0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
smb_request            0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
smb_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
isofs_inode_cache      0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
fat_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
minix_inode_cache      0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext2_inode_cache       0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext2_xattr             0      0     44   84    1 : tunables  120   60    0 : slabdata      0      0      0
journal_handle        16    123     28  123    1 : tunables  120   60    0 : slabdata      1      1      0
journal_head         119    462     48   77    1 : tunables  120   60    0 : slabdata      6      6      0
revoke_table           4    250     12  250    1 : tunables  120   60    0 : slabdata      1      1      0
revoke_record          0      0     16  200    1 : tunables  120   60    0 : slabdata      0      0      0
ext3_inode_cache     989   1638    512    7    1 : tunables   54   27    0 : slabdata    234    234      0
ext3_xattr             0      0     44   84    1 : tunables  120   60    0 : slabdata      0      0      0
dquot                  0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
eventpoll_pwq          0      0     36   99    1 : tunables  120   60    0 : slabdata      0      0      0
eventpoll_epi          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
kioctx                 0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
kiocb                  0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
dnotify_cache          0      0     20  166    1 : tunables  120   60    0 : slabdata      0      0      0
file_lock_cache        0      0     92   41    1 : tunables  120   60    0 : slabdata      0      0      0
fasync_cache           0      0     16  200    1 : tunables  120   60    0 : slabdata      0      0      0
shmem_inode_cache      3      7    512    7    1 : tunables   54   27    0 : slabdata      1      1      0
posix_timers_cache      0      0     80   48    1 : tunables  120   60    0 : slabdata      0      0      0
uid_cache              0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
bt_sock                0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
sgpool-128            32     32   2048    2    1 : tunables   24   12    0 : slabdata     16     16      0
sgpool-64             32     32   1024    4    1 : tunables   54   27    0 : slabdata      8      8      0
sgpool-32             32     32    512    8    1 : tunables   54   27    0 : slabdata      4      4      0
sgpool-16             32     45    256   15    1 : tunables  120   60    0 : slabdata      3      3      0
sgpool-8              32     60    128   30    1 : tunables  120   60    0 : slabdata      2      2      0
deadline_drq           0      0     48   77    1 : tunables  120   60    0 : slabdata      0      0      0
as_arq                10     61     60   61    1 : tunables  120   60    0 : slabdata      1      1      0
blkdev_requests       13     52    152   26    1 : tunables  120   60    0 : slabdata      2      2      0
biovec-BIO_MAX_PAGES      6      6   3072    2    2 : tunables   24   12    0 : slabdata      3      3      0
biovec-128            12     15   1536    5    2 : tunables   24   12    0 : slabdata      3      3      0
biovec-64             25     25    768    5    1 : tunables   54   27    0 : slabdata      5      5      0
biovec-16             50     60    256   15    1 : tunables  120   60    0 : slabdata      4      4      0
biovec-4             100    116     64   58    1 : tunables  120   60    0 : slabdata      2      2      0
biovec-1             163    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
bio                  276    348     64   58    1 : tunables  120   60    0 : slabdata      6      6      0
sock_inode_cache      39     50    384   10    1 : tunables   54   27    0 : slabdata      5      5      0
skbuff_head_cache    166    270    256   15    1 : tunables  120   60    0 : slabdata     18     18      0
sock                   8     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
proc_inode_cache     194    210    384   10    1 : tunables   54   27    0 : slabdata     21     21      0
sigqueue               4     26    144   26    1 : tunables  120   60    0 : slabdata      1      1      0
radix_tree_node      314    360    260   15    1 : tunables   54   27    0 : slabdata     24     24      0
bdev_cache             4      7    512    7    1 : tunables   54   27    0 : slabdata      1      1      0
mnt_cache             14     58     64   58    1 : tunables  120   60    0 : slabdata      1      1      0
inode_cache         1303   1310    384   10    1 : tunables   54   27    0 : slabdata    131    131      0
dentry_cache        1919   2130    256   15    1 : tunables  120   60    0 : slabdata    142    142      0
filp                 141    165    256   15    1 : tunables  120   60    0 : slabdata     11     11      0
names_cache            2      2   4096    1    1 : tunables   24   12    0 : slabdata      2      2      0
idr_layer_cache        3     28    136   28    1 : tunables  120   60    0 : slabdata      1      1      0
buffer_head         4550  10087     48   77    1 : tunables  120   60    0 : slabdata    131    131      0
mm_struct             28     28    512    7    1 : tunables   54   27    0 : slabdata      4      4      0
vm_area_struct       253    406     64   58    1 : tunables  120   60    0 : slabdata      7      7      0
fs_cache              29    112     32  112    1 : tunables  120   60    0 : slabdata      1      1      0
files_cache           17     21    512    7    1 : tunables   54   27    0 : slabdata      3      3      0
signal_cache          33     58     64   58    1 : tunables  120   60    0 : slabdata      1      1      0
sighand_cache         28     35   1408    5    2 : tunables   24   12    0 : slabdata      7      7      0
task_struct           34     40   1440    5    2 : tunables   24   12    0 : slabdata      8      8      0
pte_chain            629   1020    128   30    1 : tunables  120   60    0 : slabdata     34     34      0
pgd                   20     20   4096    1    1 : tunables   24   12    0 : slabdata     20     20      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-65536            15     15  65536    1   16 : tunables    8    4    0 : slabdata     15     15      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-16384             0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
size-8192             38     42   8192    1    2 : tunables    8    4    0 : slabdata     38     42      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    0 : slabdata      0      0      0
size-4096             18     18   4096    1    1 : tunables   24   12    0 : slabdata     18     18      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    0 : slabdata      0      0      0
size-2048            134    134   2048    2    1 : tunables   24   12    0 : slabdata     67     67      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    0 : slabdata      0      0      0
size-1024             48     48   1024    4    1 : tunables   54   27    0 : slabdata     12     12      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    0 : slabdata      0      0      0
size-512            8949   8960    512    8    1 : tunables   54   27    0 : slabdata   1120   1120      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
size-256             231    240    256   15    1 : tunables  120   60    0 : slabdata     16     16      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
size-128            3028   3060    128   30    1 : tunables  120   60    0 : slabdata    102    102      0
size-64(DMA)           0      0     64   58    1 : tunables  120   60    0 : slabdata      0      0      0
size-64             1137   1160     64   58    1 : tunables  120   60    0 : slabdata     20     20      0
size-32(DMA)           0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
size-32             1344   1344     32  112    1 : tunables  120   60    0 : slabdata     12     12      0
kmem_cache           132    132    116   33    1 : tunables  120   60    0 : slabdata      4      4      0

--Boundary-00=_Gxp5AgcDKWYXuES
Content-Type: text/plain;
  charset="iso-8859-1";
  name="slabinfo.wocompress"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="slabinfo.wocompress"

slabinfo - version: 2.0
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ip_fib_hash           32    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
clip_arp_cache         0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
fib6_nodes             9    112     32  112    1 : tunables  120   60    0 : slabdata      1      1      0
ip6_dst_cache         13     30    256   15    1 : tunables  120   60    0 : slabdata      2      2      0
ndisc_cache            1     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
raw6_sock              0      0    640    6    1 : tunables   54   27    0 : slabdata      0      0      0
udp6_sock              2      6    640    6    1 : tunables   54   27    0 : slabdata      1      1      0
tcp6_sock              5      7   1152    7    2 : tunables   24   12    0 : slabdata      1      1      0
unix_sock              7     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
ip_vs_conn             0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
ip_conntrack        1192   2060    384   10    1 : tunables   54   27    0 : slabdata    206    206      0
ip_mrt_cache           0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
tcp_tw_bucket          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
tcp_bind_bucket        1    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
tcp_open_request       0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
inet_peer_cache       72    116     64   58    1 : tunables  120   60    0 : slabdata      2      2      0
secpath_cache          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
xfrm_dst_cache         3     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
ip_dst_cache        4644   4660    384   10    1 : tunables   54   27    0 : slabdata    466    466      0
arp_cache              7     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
raw4_sock              0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
udp_sock              16     21    512    7    1 : tunables   54   27    0 : slabdata      3      3      0
tcp_sock               2      4   1024    4    1 : tunables   54   27    0 : slabdata      1      1      0
flow_cache           401    870    128   30    1 : tunables  120   60    0 : slabdata     29     29      0
hpsb_packet            0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
udf_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
romfs_inode_cache      0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
smb_request            0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
smb_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
isofs_inode_cache      0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
fat_inode_cache        0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
minix_inode_cache      0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext2_inode_cache       0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
ext2_xattr             0      0     44   84    1 : tunables  120   60    0 : slabdata      0      0      0
journal_handle         8    123     28  123    1 : tunables  120   60    0 : slabdata      1      1      0
journal_head          82    462     48   77    1 : tunables  120   60    0 : slabdata      6      6      0
revoke_table           4    250     12  250    1 : tunables  120   60    0 : slabdata      1      1      0
revoke_record          0      0     16  200    1 : tunables  120   60    0 : slabdata      0      0      0
ext3_inode_cache     988   1638    512    7    1 : tunables   54   27    0 : slabdata    234    234      0
ext3_xattr             0      0     44   84    1 : tunables  120   60    0 : slabdata      0      0      0
dquot                  0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
eventpoll_pwq          0      0     36   99    1 : tunables  120   60    0 : slabdata      0      0      0
eventpoll_epi          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
kioctx                 0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
kiocb                  0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
dnotify_cache          0      0     20  166    1 : tunables  120   60    0 : slabdata      0      0      0
file_lock_cache        0      0     92   41    1 : tunables  120   60    0 : slabdata      0      0      0
fasync_cache           0      0     16  200    1 : tunables  120   60    0 : slabdata      0      0      0
shmem_inode_cache      3      7    512    7    1 : tunables   54   27    0 : slabdata      1      1      0
posix_timers_cache      0      0     80   48    1 : tunables  120   60    0 : slabdata      0      0      0
uid_cache              0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
bt_sock                0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
sgpool-128            32     32   2048    2    1 : tunables   24   12    0 : slabdata     16     16      0
sgpool-64             32     32   1024    4    1 : tunables   54   27    0 : slabdata      8      8      0
sgpool-32             32     32    512    8    1 : tunables   54   27    0 : slabdata      4      4      0
sgpool-16             32     45    256   15    1 : tunables  120   60    0 : slabdata      3      3      0
sgpool-8              32     60    128   30    1 : tunables  120   60    0 : slabdata      2      2      0
deadline_drq           0      0     48   77    1 : tunables  120   60    0 : slabdata      0      0      0
as_arq                13     61     60   61    1 : tunables  120   60    0 : slabdata      1      1      0
blkdev_requests       18     52    152   26    1 : tunables  120   60    0 : slabdata      2      2      0
biovec-BIO_MAX_PAGES      6      6   3072    2    2 : tunables   24   12    0 : slabdata      3      3      0
biovec-128            12     15   1536    5    2 : tunables   24   12    0 : slabdata      3      3      0
biovec-64             25     25    768    5    1 : tunables   54   27    0 : slabdata      5      5      0
biovec-16             55     60    256   15    1 : tunables  120   60    0 : slabdata      4      4      0
biovec-4             108    116     64   58    1 : tunables  120   60    0 : slabdata      2      2      0
biovec-1             115    200     16  200    1 : tunables  120   60    0 : slabdata      1      1      0
bio                  276    348     64   58    1 : tunables  120   60    0 : slabdata      6      6      0
sock_inode_cache      39     40    384   10    1 : tunables   54   27    0 : slabdata      4      4      0
skbuff_head_cache    166    270    256   15    1 : tunables  120   60    0 : slabdata     18     18      0
sock                   8     10    384   10    1 : tunables   54   27    0 : slabdata      1      1      0
proc_inode_cache     199    210    384   10    1 : tunables   54   27    0 : slabdata     21     21      0
sigqueue               8     26    144   26    1 : tunables  120   60    0 : slabdata      1      1      0
radix_tree_node      304    360    260   15    1 : tunables   54   27    0 : slabdata     24     24      0
bdev_cache             4      7    512    7    1 : tunables   54   27    0 : slabdata      1      1      0
mnt_cache             14     58     64   58    1 : tunables  120   60    0 : slabdata      1      1      0
inode_cache         1305   1310    384   10    1 : tunables   54   27    0 : slabdata    131    131      0
dentry_cache        1918   2145    256   15    1 : tunables  120   60    0 : slabdata    143    143      0
filp                 141    165    256   15    1 : tunables  120   60    0 : slabdata     11     11      0
names_cache            1      2   4096    1    1 : tunables   24   12    0 : slabdata      1      2      0
idr_layer_cache        3     28    136   28    1 : tunables  120   60    0 : slabdata      1      1      0
buffer_head         5001  10087     48   77    1 : tunables  120   60    0 : slabdata    131    131      0
mm_struct             28     28    512    7    1 : tunables   54   27    0 : slabdata      4      4      0
vm_area_struct       271    406     64   58    1 : tunables  120   60    0 : slabdata      7      7      0
fs_cache              23    112     32  112    1 : tunables  120   60    0 : slabdata      1      1      0
files_cache           18     21    512    7    1 : tunables   54   27    0 : slabdata      3      3      0
signal_cache          39     58     64   58    1 : tunables  120   60    0 : slabdata      1      1      0
sighand_cache         28     30   1408    5    2 : tunables   24   12    0 : slabdata      6      6      0
task_struct           35     40   1440    5    2 : tunables   24   12    0 : slabdata      7      8      0
pte_chain            592   1020    128   30    1 : tunables  120   60    0 : slabdata     34     34      0
pgd                   18     20   4096    1    1 : tunables   24   12    0 : slabdata     18     20      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-65536            13     13  65536    1   16 : tunables    8    4    0 : slabdata     13     13      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-16384             0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
size-8192             39     41   8192    1    2 : tunables    8    4    0 : slabdata     39     41      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    0 : slabdata      0      0      0
size-4096             18     18   4096    1    1 : tunables   24   12    0 : slabdata     18     18      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    0 : slabdata      0      0      0
size-2048            129    134   2048    2    1 : tunables   24   12    0 : slabdata     67     67      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    0 : slabdata      0      0      0
size-1024             44     48   1024    4    1 : tunables   54   27    0 : slabdata     12     12      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    0 : slabdata      0      0      0
size-512            8949   8960    512    8    1 : tunables   54   27    0 : slabdata   1120   1120      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
size-256             232    240    256   15    1 : tunables  120   60    0 : slabdata     16     16      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
size-128            3036   3060    128   30    1 : tunables  120   60    0 : slabdata    102    102      0
size-64(DMA)           0      0     64   58    1 : tunables  120   60    0 : slabdata      0      0      0
size-64             1147   1160     64   58    1 : tunables  120   60    0 : slabdata     20     20      0
size-32(DMA)           0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
size-32             1320   1344     32  112    1 : tunables  120   60    0 : slabdata     12     12      0
kmem_cache           132    132    116   33    1 : tunables  120   60    0 : slabdata      4      4      0

--Boundary-00=_Gxp5AgcDKWYXuES--
