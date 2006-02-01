From: Sai Bathina <sai.bathina@gmail.com>
Subject: Re: 2.6.14.3 and page allocation failures..
Date: Wed, 1 Feb 2006 08:35:57 -0500
Message-ID: <32e47b670602010535l4346f4dej5612e25340190b0d@mail.gmail.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C06909DA8@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C06909DA8@orsmsx408>
Content-Disposition: inline
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Thanks for the post:

Here's the /proc/slabinfo output:
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab>
<pagesperslab> : tunables <limit> <batchcount> <sharedfactor> :
slabdata <activ
e_slabs> <num_slabs> <sharedavail>
ip_conntrack_syn       0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
ip_fib_alias           9    113     32  113    1 : tunables  120   60=20
  8 : slabdata      1      1      0
ip_fib_hash            9    113     32  113    1 : tunables  120   60=20
  8 : slabdata      1      1      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12=20
  8 : slabdata      4      4      0
rpc_tasks              8     15    256   15    1 : tunables  120   60=20
  8 : slabdata      1      1      0
rpc_inode_cache        0      0    512    7    1 : tunables   54   27=20
  8 : slabdata      0      0      0
bridge_fdb_cache       4     59     64   59    1 : tunables  120   60=20
  8 : slabdata      1      1      0
UNIX                   7      7    512    7    1 : tunables   54   27=20
  8 : slabdata      1      1      0
ipt_hashlimit          0      0     40   92    1 : tunables  120   60=20
  8 : slabdata      0      0      0
ip_tproxy              0      0    128   30    1 : tunables  120   60=20
  8 : slabdata      0      0      0
ip_conntrack_expect      0      0     96   40    1 : tunables  120 =20
60    8 : slabdata      0      0      0
ip_conntrack           1     16    248   16    1 : tunables  120   60=20
  8 : slabdata      1      1      0
tcp_bind_bucket        1    203     16  203    1 : tunables  120   60=20
  8 : slabdata      1      1      0
inet_peer_cache        0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
ip_dst_cache           0      0    256   15    1 : tunables  120   60=20
  8 : slabdata      0      0      0
arp_cache              0      0    256   15    1 : tunables  120   60=20
  8 : slabdata      0      0      0
RAW                    3      7    512    7    1 : tunables   54   27=20
  8 : slabdata      1      1      0
UDP                    0      0    512    7    1 : tunables   54   27=20
  8 : slabdata      0      0      0
tw_sock_TCP            0      0    128   30    1 : tunables  120   60=20
  8 : slabdata      0      0      0
request_sock_TCP       0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
TCP                    4      7   1152    7    2 : tunables   24   12=20
  8 : slabdata      1      1      0
cfq_ioc_pool           0      0     48   78    1 : tunables  120   60=20
  8 : slabdata      0      0      0
cfq_pool               0      0     96   40    1 : tunables  120   60=20
  8 : slabdata      0      0      0
crq_pool               0      0     48   78    1 : tunables  120   60=20
  8 : slabdata      0      0      0
deadline_drq           0      0     52   72    1 : tunables  120   60=20
  8 : slabdata      0      0      0
as_arq                12     59     64   59    1 : tunables  120   60=20
  8 : slabdata      1      1      0
mqueue_inode_cache      1      6    640    6    1 : tunables   54   27
   8 : slabdata      1      1      0
nfs_write_data        36     42    512    7    1 : tunables   54   27=20
  8 : slabdata      6      6      0
nfs_read_data         32     35    512    7    1 : tunables   54   27=20
  8 : slabdata      5      5      0
nfs_inode_cache        0      0    668    6    1 : tunables   54   27=20
  8 : slabdata      0      0      0
nfs_page               0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
ext2_inode_cache     649    816    492    8    1 : tunables   54   27=20
  8 : slabdata    102    102      0
dnotify_cache          0      0     20  169    1 : tunables  120   60=20
  8 : slabdata      0      0      0
eventpoll_pwq          0      0     36  101    1 : tunables  120   60=20
  8 : slabdata      0      0      0
eventpoll_epi          0      0    128   30    1 : tunables  120   60=20
  8 : slabdata      0      0      0
inotify_event_cache      0      0     28  127    1 : tunables  120 =20
60    8 : slabdata      0      0      0
inotify_watch_cache      0      0     36  101    1 : tunables  120 =20
60    8 : slabdata      0      0      0
kioctx                 0      0    256   15    1 : tunables  120   60=20
  8 : slabdata      0      0      0
kiocb                  0      0    128   30    1 : tunables  120   60=20
  8 : slabdata      0      0      0
fasync_cache           0      0     16  203    1 : tunables  120   60=20
  8 : slabdata      0      0      0
shmem_inode_cache      3      8    476    8    1 : tunables   54   27=20
  8 : slabdata      1      1      0
posix_timers_cache      0      0    104   37    1 : tunables  120   60
   8 : slabdata      0      0      0
uid_cache              0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
sgpool-128            32     32   2048    2    1 : tunables   24   12=20
  8 : slabdata     16     16      0
sgpool-64             32     32   1024    4    1 : tunables   54   27=20
  8 : slabdata      8      8      0
sgpool-32             32     32    512    8    1 : tunables   54   27=20
  8 : slabdata      4      4      0
sgpool-16             32     45    256   15    1 : tunables  120   60=20
  8 : slabdata      3      3      0
sgpool-8              32     60    128   30    1 : tunables  120   60=20
  8 : slabdata      2      2      0
blkdev_ioc            33    127     28  127    1 : tunables  120   60=20
  8 : slabdata      1      1      0
blkdev_queue          26     27    412    9    1 : tunables   54   27=20
  8 : slabdata      3      3      0
blkdev_requests       24     48    160   24    1 : tunables  120   60=20
  8 : slabdata      2      2      0
biovec-(256)         256    256   3072    2    2 : tunables   24   12=20
  8 : slabdata    128    128      0
biovec-128           256    260   1536    5    2 : tunables   24   12=20
  8 : slabdata     52     52      0
biovec-64            256    260    768    5    1 : tunables   54   27=20
  8 : slabdata     52     52      0
biovec-16            259    270    256   15    1 : tunables  120   60=20
  8 : slabdata     18     18      0
biovec-4             256    295     64   59    1 : tunables  120   60=20
  8 : slabdata      5      5      0
biovec-1             272    406     16  203    1 : tunables  120   60=20
  8 : slabdata      2      2      0
bio                  317   1170    128   30    1 : tunables  120   60=20
  8 : slabdata     39     39      0
file_lock_cache       11     40     96   40    1 : tunables  120   60=20
  8 : slabdata      1      1      0
sock_inode_cache      21     21    512    7    1 : tunables   54   27=20
  8 : slabdata      3      3      0
skbuff_fclone_cache      0      0    384   10    1 : tunables   54 =20
27    8 : slabdata      0      0      0
skbuff_head_cache  32955  32955    256   15    1 : tunables  120   60=20
  8 : slabdata   2197   2197      0
proc_inode_cache      70    170    392   10    1 : tunables   54   27=20
  8 : slabdata     17     17      0
sigqueue               8     26    148   26    1 : tunables  120   60=20
  8 : slabdata      1      1      0
radix_tree_node      698    728    276   14    1 : tunables   54   27=20
  8 : slabdata     52     52      0
bdev_cache             7      7    512    7    1 : tunables   54   27=20
  8 : slabdata      1      1      0
sysfs_dir_cache     1202   1288     40   92    1 : tunables  120   60=20
  8 : slabdata     14     14      0
mnt_cache             17     30    128   30    1 : tunables  120   60=20
  8 : slabdata      1      1      0
inode_cache          340    340    376   10    1 : tunables   54   27=20
  8 : slabdata     34     34      0
dentry_cache        1095   1701    144   27    1 : tunables  120   60=20
  8 : slabdata     63     63      0
filp                 390    495    256   15    1 : tunables  120   60=20
  8 : slabdata     33     33      0
names_cache           12     12   4096    1    1 : tunables   24   12=20
  8 : slabdata     12     12      0
idr_layer_cache       64     87    136   29    1 : tunables  120   60=20
  8 : slabdata      3      3      0
buffer_head          900   1224     52   72    1 : tunables  120   60=20
  8 : slabdata     17     17      0
mm_struct             48     48    640    6    1 : tunables   54   27=20
  8 : slabdata      8      8      0
vm_area_struct       576    748     88   44    1 : tunables  120   60=20
  8 : slabdata     17     17      0
fs_cache              59     59     64   59    1 : tunables  120   60=20
  8 : slabdata      1      1      0
files_cache           56     56    512    7    1 : tunables   54   27=20
  8 : slabdata      8      8      0
signal_cache          70     70    384   10    1 : tunables   54   27=20
  8 : slabdata      7      7      0
sighand_cache         65     65   1408    5    2 : tunables   24   12=20
  8 : slabdata     13     13      0
task_struct           66     66   1280    3    1 : tunables   24   12=20
  8 : slabdata     22     22      0
anon_vma             367    406     16  203    1 : tunables  120   60=20
  8 : slabdata      2      2      0
pgd                   48     48   4096    1    1 : tunables   24   12=20
  8 : slabdata     48     48      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4=20
  0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4=20
  0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4=20
  0 : slabdata      0      0      0
size-65536             3      3  65536    1   16 : tunables    8    4=20
  0 : slabdata      3      3      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4=20
  0 : slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4=20
  0 : slabdata      0      0      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4=20
  0 : slabdata      0      0      0
size-16384             0      0  16384    1    4 : tunables    8    4=20
  0 : slabdata      0      0      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4=20
  0 : slabdata      0      0      0
size-8192             58     58   8192    1    2 : tunables    8    4=20
  0 : slabdata     58     58      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12=20
  8 : slabdata      0      0      0
size-4096             46     46   4096    1    1 : tunables   24   12=20
  8 : slabdata     46     46      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12=20
  8 : slabdata      0      0      0
size-2048          33000  33000   2048    2    1 : tunables   24   12=20
  8 : slabdata  16500  16500     24
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27=20
  8 : slabdata      0      0      0
size-1024             80     80   1024    4    1 : tunables   54   27=20
  8 : slabdata     20     20      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27=20
  8 : slabdata      0      0      0
size-512             184    184    512    8    1 : tunables   54   27=20
  8 : slabdata     23     23      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60=20
  8 : slabdata      0      0      0
size-256             120    120    256   15    1 : tunables  120   60=20
  8 : slabdata      8      8      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60=20
  8 : slabdata      0      0      0
size-128             900    900    128   30    1 : tunables  120   60=20
  8 : slabdata     30     30      0
size-64(DMA)           0      0     64   59    1 : tunables  120   60=20
  8 : slabdata      0      0      0
size-32(DMA)           0      0     32  113    1 : tunables  120   60=20
  8 : slabdata      0      0      0
size-64            82658  82718     64   59    1 : tunables  120   60=20
  8 : slabdata   1402   1402      0
size-32              851    904     32  113    1 : tunables  120   60=20
  8 : slabdata      8      8      0
kmem_cache           120    120    128   30    1 : tunables  120   60=20
  8 : slabdata      4      4      0


On 1/31/06, Brandeburg, Jesse <jesse.brandeburg@intel.com> wrote:
> Sorry for the top post.
>
> You may want to post this to netdev@vger.kernel.org.
>
> We haven't heard any reports of e100 itself leaking.  You need to run
> slabtop or send the output of /proc/slabinfo to see what slab entry is
> taking all the memory on your system.
>
> At this point some other component is suspect.
>
> Jesse
>
>
> > -----Original Message-----
> > From: e1000-devel-admin@lists.sourceforge.net [mailto:e1000-devel-
> > admin@lists.sourceforge.net] On Behalf Of Sai Bathina
> > Sent: Monday, January 30, 2006 4:03 PM
> > To: e1000-devel@lists.sourceforge.net
> > Subject: [E1000-devel] 2.6.14.3 and page allocation failures..
> >
> > Hi,
> >      I am seeing page allocation errors and I have a snapshot of the
> > /var/log/messages.
> >
> > My Hardware configs are
> > Dell 650, using e100 driver(e100-3.4.14-k2-NAPI), driver from the
> kernel
> >
> > model name      : Intel(R) Pentium(R) 4 CPU 2.40GHz cache size      :
> > 512 KB
> >
> >   total       used       free     shared    buffers     cached
> > Mem:        255744     188400      67344          0        680
> 11064
> > -/+ buffers/cache:     176656      79088
> > Swap:      2097136     134740    1962396
> >
> >
> > Observed the failures immediately after running network traffic.
> > I am assuming that it has something to do with the e100 driver page
> > allocations here....I would appreciate if anyone can help me in
> > figuring out what is going wrong with this.
> >
> > Jan 30 22:46:59 : swapper: page allocation failure. order:0, mode:0x20
> > Jan 30 22:46:59 :  [__alloc_pages+936/976] __alloc_pages+0x3a8/0x3d0
> > Jan 30 22:46:59 :  [br_nf_forward_ip+264/296]
> br_nf_forward_ip+0x108/0x128
> > Jan 30 22:46:59 :  [kmem_getpages+44/132] kmem_getpages+0x2c/0x84
> > Jan 30 22:46:59 :  [cache_grow+163/316] cache_grow+0xa3/0x13c
> > Jan 30 22:46:59 :  [cache_alloc_refill+415/488]
> > cache_alloc_refill+0x19f/0x1e8
> > Jan 30 22:46:59 :  [skb_checksum+72/628] skb_checksum+0x48/0x274
> > Jan 30 22:46:59 :  [kmem_cache_alloc+63/76] kmem_cache_alloc+0x3f/0x4c
> > Jan 30 22:47:00 :  [ip_conntrack_alloc+133/280]
> > ip_conntrack_alloc+0x85/0x118
> > Jan 30 22:47:00 :  [init_conntrack+48/348] init_conntrack+0x30/0x15c
> > Jan 30 22:47:00 :  [rpc_get_inode+52/148] rpc_get_inode+0x34/0x94
> > Jan 30 22:47:00 :  [ip_conntrack_in+317/824]
> ip_conntrack_in+0x13d/0x338
> > Jan 30 22:47:00 :  [br_nf_pre_routing_finish+0/704]
> > br_nf_pre_routing_finish+0x0/0x2c0
> > Jan 30 22:47:00 :  [nf_iterate+69/112] nf_iterate+0x45/0x70
> > Jan 30 22:47:00 :  [br_nf_pre_routing_finish+0/704]
> > br_nf_pre_routing_finish+0x0/0x2c0
> > Jan 30 22:47:00 :  [nf_hook_slow+100/260] nf_hook_slow+0x64/0x104
> > Jan 30 22:47:00 :  [br_nf_pre_routing_finish+0/704]
> > br_nf_pre_routing_finish+0x0/0x2c0
> > Jan 30 22:47:00 :  [br_handle_frame_finish+0/220]
> > br_handle_frame_finish+0x0/0xdc
> > Jan 30 22:47:00 :  [br_nf_pre_routing+907/948]
> > br_nf_pre_routing+0x38b/0x3b4
> > Jan 30 22:47:00 :  [br_nf_pre_routing_finish+0/704]
> > br_nf_pre_routing_finish+0x0/0x2c0
> > Jan 30 22:47:00 :  [br_handle_frame_finish+0/220]
> > br_handle_frame_finish+0x0/0xdc
> > Jan 30 22:47:00 :  [nf_iterate+69/112] nf_iterate+0x45/0x70
> > Jan 30 22:47:00 :  [br_handle_frame_finish+0/220]
> > br_handle_frame_finish+0x0/0xdc
> > Jan 30 22:47:00 :  [nf_hook_slow+100/260] nf_hook_slow+0x64/0x104
> > Jan 30 22:47:00 :  [br_handle_frame_finish+0/220]
> > br_handle_frame_finish+0x0/0xdc
> > Jan 30 22:47:00 :  [br_handle_frame+385/476]
> br_handle_frame+0x181/0x1dc
> > Jan 30 22:47:00 :  [br_handle_frame_finish+0/220]
> > br_handle_frame_finish+0x0/0xdc
> > Jan 30 22:47:00 :  [netif_receive_skb+322/576]
> > netif_receive_skb+0x142/0x240
> > Jan 30 22:47:00 :  [pg0+273725344/1069114368] e100_poll+0x274/0x6bc
> [e100]
> > Jan 30 22:47:00 :  [net_rx_action+128/296] net_rx_action+0x80/0x128
> > Jan 30 22:47:00 :  [gcc2_compiled.+141/256] __do_softirq+0x8d/0x100
> > Jan 30 22:47:00 :  [do_softirq+47/52] do_softirq+0x2f/0x34
> > Jan 30 22:47:00 :  [irq_exit+52/64] irq_exit+0x34/0x40
> > Jan 30 22:47:00 :  [gcc2_compiled.+32/40] do_IRQ+0x20/0x28
> > Jan 30 22:47:00 :  [common_interrupt+26/32] common_interrupt+0x1a/0x20
> > Jan 30 22:47:00 :  [default_idle+0/44] default_idle+0x0/0x2c
> > Jan 30 22:47:00 :  [default_idle+35/44] default_idle+0x23/0x2c
> > Jan 30 22:47:00 :  [cpu_idle+123/140] cpu_idle+0x7b/0x8c
> > Jan 30 22:47:00 :  [rest_init+45/48] rest_init+0x2d/0x30
> > Jan 30 22:47:00 :  [start_kernel+402/404] start_kernel+0x192/0x194
> > Jan 30 22:47:00 : Mem-info:
> > Jan 30 22:47:00 : DMA per-cpu:
> > Jan 30 22:47:00 : cpu 0 hot: low 2, high 6, batch 1 used:2
> > Jan 30 22:47:00 : cpu 0 cold: low 0, high 2, batch 1 used:0
> > Jan 30 22:47:00 : Normal per-cpu:
> > Jan 30 22:47:00 : cpu 0 hot: low 62, high 186, batch 31 used:92
> > Jan 30 22:47:00 : cpu 0 cold: low 0, high 62, batch 31 used:59
> > Jan 30 22:47:00 : HighMem per-cpu: empty
> > Jan 30 22:47:00 : Free pages:        1724kB (0kB HighMem)
> > Jan 30 22:47:00 : Active:42014 inactive:17287 dirty:18 writeback:0
> > unstable:0 free:431 slab:2213 mapped:57515 pagetables:162
> > Jan 30 22:47:00 : DMA free:1004kB min:124kB low:152kB high:184kB
> > active:5396kB inactive:5872kB present:16384kB pages_scanned:0
> > all_unreclaimable? no
> > Jan 30 22:47:00 : lowmem_reserve[]: 0 239 239
> > Jan 30 22:47:00 : Normal free:720kB min:1916kB low:2392kB high:2872kB
> > active:162660kB inactive:63276kB present:245696kB pages_scanned:0
> > all_unreclaimable? no
> > Jan 30 22:47:00 : lowmem_reserve[]: 0 0 0
> > Jan 30 22:47:00 : HighMem free:0kB min:128kB low:160kB high:192kB
> > active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable?
> > no
> > Jan 30 22:47:00 : lowmem_reserve[]: 0 0 0
> > Jan 30 22:47:00 : DMA: 1*4kB 1*8kB 0*16kB 1*32kB 1*64kB 1*128kB
> > 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1004kB
> > Jan 30 22:47:00 : Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB
> > 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 720kB
> >
> > Jan 30 22:47:00 : HighMem: empty
> > Jan 30 22:47:00 : Swap cache: add 2750, delete 2255, find 199/211,
> race
> > 0+0
> > Jan 30 22:47:00 : Free swap  =3D 2086600kB
> > Jan 30 22:47:00 : Total swap =3D 2097136kB
> > Jan 30 22:47:00 : Free swap:       2086600kB
> > Jan 30 22:47:00 : 65520 pages of RAM
> > Jan 30 22:47:00 : 0 pages of HIGHMEM
> > Jan 30 22:47:00 : 2608 reserved pages
> > Jan 30 22:47:00 : 3922 pages shared
> > Jan 30 22:47:00 : 495 pages swap cached
> > Jan 30 22:47:00 : 18 pages dirty
> > Jan 30 22:47:00 : 0 pages writeback
> > Jan 30 22:47:00 : 57515 pages mapped
> > Jan 30 22:47:00 : 2213 pages slab
> > Jan 30 22:47:00 : 162 pages pagetables
> > Jan 30 22:47:02 : snort2: page allocation failure. order:0, mode:0x20
> > Jan 30 22:47:02 :  [__alloc_pages+936/976] __alloc_pages+0x3a8/0x3d0
> > Jan 30 22:47:02 :  [kmem_getpages+44/132] kmem_getpages+0x2c/0x84
> > Jan 30 22:47:02 :  [cache_grow+163/316] cache_grow+0xa3/0x13c
> > Jan 30 22:47:02 :  [cache_alloc_refill+415/488]
> > cache_alloc_refill+0x19f/0x1e8
> > Jan 30 22:47:02 :  [__kmalloc+115/136] __kmalloc+0x73/0x88
> > Jan 30 22:47:02 :  [__alloc_skb+88/292] __alloc_skb+0x58/0x124
> > Jan 30 22:47:02 :  [pg0+273725486/1069114368] e100_poll+0x302/0x6bc
> [e100]
> > Jan 30 22:47:02 :  [net_rx_action+128/296] net_rx_action+0x80/0x128
> > Jan 30 22:47:02 :  [gcc2_compiled.+141/256] __do_softirq+0x8d/0x100
> > Jan 30 22:47:02 :  [do_softirq+47/52] do_softirq+0x2f/0x34
> > Jan 30 22:47:02 :  [irq_exit+52/64] irq_exit+0x34/0x40
> > Jan 30 22:47:02 :  [gcc2_compiled.+32/40] do_IRQ+0x20/0x28
> > Jan 30 22:47:02 :  [common_interrupt+26/32] common_interrupt+0x1a/0x20
> > Jan 30 22:47:02 : Mem-info:
> > Jan 30 22:47:02 : DMA per-cpu:
> > Jan 30 22:47:02 : cpu 0 hot: low 2, high 6, batch 1 used:2
> > Jan 30 22:47:02 : cpu 0 cold: low 0, high 2, batch 1 used:1
> > Jan 30 22:47:02 : Normal per-cpu:
> > Jan 30 22:47:02 : cpu 0 hot: low 62, high 186, batch 31 used:92
> > Jan 30 22:47:02 : cpu 0 cold: low 0, high 62, batch 31 used:44
> > Jan 30 22:47:02 : HighMem per-cpu: empty
> > Jan 30 22:47:02 : Free pages:        1616kB (0kB HighMem)
> > Jan 30 22:47:02 : Active:26538 inactive:14460 dirty:0 writeback:1337
> > unstable:0 free:404 slab:20545 mapped:26431 pagetables:168
> > Jan 30 22:47:02 : DMA free:1004kB min:124kB low:152kB high:184kB
> > active:2768kB inactive:2032kB present:16384kB pages_scanned:0
> > all_unreclaimable? no
> > Jan 30 22:47:02 : lowmem_reserve[]: 0 239 239
> > Jan 30 22:47:02 : Normal free:612kB min:1916kB low:2392kB high:2872kB
> > active:103384kB inactive:55808kB present:245696kB pages_scanned:0
> > all_unreclaimable? no
> > Jan 30 22:47:02 : lowmem_reserve[]: 0 0 0
> > Jan 30 22:47:02 : HighMem free:0kB min:128kB low:160kB high:192kB
> > active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable?
> > no
> > Jan 30 22:47:02 : lowmem_reserve[]: 0 0 0
> > Jan 30 22:47:02 : DMA: 1*4kB 1*8kB 0*16kB 1*32kB 1*64kB 1*128kB
> > 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1004kB
> > Jan 30 22:47:02 : Normal: 1*4kB 0*8kB 0*16kB 1*32kB 1*64kB 0*128kB
> > 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 612kB
> > Jan 30 22:47:02 : HighMem: empty
> > Jan 30 22:47:02 : Swap cache: add 34195, delete 20265, find 291/345,
> race
> > 0+0
> > Jan 30 22:47:02 : Free swap  =3D 1962140kB
> > Jan 30 22:47:02 : Total swap =3D 2097136kB
> > Jan 30 22:47:02 : Free swap:       1962140kB
> > Jan 30 22:47:02 : 65520 pages of RAM
> > Jan 30 22:47:02 : 0 pages of HIGHMEM
> > Jan 30 22:47:02 : 2608 reserved pages
> > Jan 30 22:47:02 : 3785 pages shared
> > Jan 30 22:47:02 : 13930 pages swap cached
> > Jan 30 22:47:02 : 0 pages dirty
> > Jan 30 22:47:02 : 1337 pages writeback
> > Jan 30 22:47:02 : 26431 pages mapped
> > Jan 30 22:47:02 : 20545 pages slab
> > Jan 30 22:47:02 : 168 pages pagetables
> >
> >
> > -------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc. Do you grep through log
> > files
> > for problems?  Stop!  Download the new AJAX search engine that makes
> > searching your log files as easy as surfing the  web.  DOWNLOAD
> SPLUNK!
> > http://sel.as-us.falkag.net/sel?cmd=3Dk&kid=103432&bid#0486&dat=121642
> > _______________________________________________
> > E1000-devel mailing list
> > E1000-devel@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/e1000-devel
>


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
