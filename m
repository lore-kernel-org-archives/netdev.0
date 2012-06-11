From: Marco Berizzi <pupilla@hotmail.com>
Subject: kernel ipsec error
Date: Mon, 11 Jun 2012 14:45:20 +0200
Message-ID: <DUB108-W3906ACEA67D9618490CB02B2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s8.dub0.hotmail.com ([157.55.0.207]:10300 "EHLO
	dub0-omc1-s8.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754285Ab2FKMpW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 08:45:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello everybody.

After 12 days uptime I got this message.
Linux is 3.3.5 32bit, running openswan
(this is an ipsec gateway/netfilter
firewall) and squid.

Jun 11 12:53:02 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
Jun 11 12:53:02 Pleiadi kernel:=A0=A0 cache: kmalloc-2048, object size:=
 2048, buffer size: 2048, default order: 2, min order: 0
Jun 11 12:53:02 Pleiadi kernel:=A0=A0 node 0: slabs: 61, objs: 476, fre=
e: 0
Jun 11 12:53:02 Pleiadi kernel: kworker/0:2: page allocation failure: o=
rder:0, mode:0x4020
Jun 11 12:53:02 Pleiadi kernel: Pid: 18004, comm: kworker/0:2 Not taint=
ed 3.3.5 #1
Jun 11 12:53:02 Pleiadi kernel: Call Trace:
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c104eada>] ? warn_alloc_failed+0xb=
7/0xc8
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c104efbb>] ? __alloc_pages_nodemas=
k+0x4d0/0x4dd
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1067754>] ? allocate_slab+0x57/0x=
bf
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c10677f4>] ? new_slab+0x1f/0x11a
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c10682dc>] ? __slab_alloc+0x13e/0x=
20e
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c104ccc3>] ? mempool_free+0x47/0x4=
a
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c106967f>] ? __kmalloc_track_calle=
r+0x66/0xc2
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1184261>] ? __netdev_alloc_skb+0x=
14/0x2d
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1184261>] ? __netdev_alloc_skb+0x=
14/0x2d
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1184109>] ? __alloc_skb+0x4f/0xfc
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1184118>] ? __alloc_skb+0x5e/0xfc
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1184261>] ? __netdev_alloc_skb+0x=
14/0x2d
Jun 11 12:53:02 Pleiadi kernel:=A0 [<cac211ab>] ? boomerang_rx+0x305/0x=
41c [3c59x]
Jun 11 12:53:02 Pleiadi kernel:=A0 [<cac209dc>] ? boomerang_interrupt+0=
x96/0x2c3 [3c59x]
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c104082d>] ? handle_irq_event_perc=
pu+0x26/0xe5
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1041f50>] ? cond_unmask_irq+0x1f/=
0x1f
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1040905>] ? handle_irq_event+0x19=
/0x24
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1041fad>] ? handle_level_irq+0x5d=
/0x67
Jun 11 12:53:02 Pleiadi kernel:=A0 <IRQ>=A0 [<c10033da>] ? do_IRQ+0x2b/=
0x7b
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11fc989>] ? common_interrupt+0x29=
/0x30
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e007b>] ? bictcp_cong_avoid+0x2=
1c/0x337
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e20a1>] ? xfrm_policy_lookup_by=
type+0x12a/0x144
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e20d1>] ? __xfrm_policy_lookup+=
0x16/0x1a
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e2e8b>] ? xfrm_bundle_lookup+0x=
e2/0x2e6
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e2110>] ? xfrm_policy_lookup+0x=
3b/0x56
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1199b15>] ? flow_cache_lookup+0x1=
02/0x203
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1199bd3>] ? flow_cache_lookup+0x1=
c0/0x203
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e3219>] ? xfrm_lookup+0x151/0x3=
56
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e2da9>] ? xfrm_resolve_and_crea=
te_bundle+0x87/0x87
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11de161>] ? alloc_null_binding+0x=
22/0x27
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11de187>] ? nf_nat_rule_find+0x21=
/0x63
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11de1c0>] ? nf_nat_rule_find+0x5a=
/0x63
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11e39a4>] ? __xfrm_route_forward+=
0x60/0x7b
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11a9882>] ? ipv4_validate_peer+0x=
9/0x5c
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11ad72c>] ? ip_forward+0xe9/0x2c9
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11ac67a>] ? ip_rcv_finish+0x272/0=
x285
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11ac8a8>] ? ip_rcv+0x21b/0x23f
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c118cd74>] ? __netif_receive_skb+0=
x22e/0x254
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c118d57f>] ? process_backlog+0x48/=
0xfe
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c118d7bf>] ? net_rx_action+0x5f/0x=
fb
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c101f339>] ? __do_softirq+0x59/0xc=
2
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c101f2e0>] ? local_bh_enable_ip+0x=
77/0x77
Jun 11 12:53:02 Pleiadi kernel:=A0 <IRQ>=A0 [<c101f25d>] ? local_bh_ena=
ble+0x6b/0x77
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11934e3>] ? neigh_periodic_work+0=
xbc/0xfa
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c102919c>] ? process_one_work+0x13=
b/0x22f
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1193427>] ? neigh_connect+0x10/0x=
10
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c1029377>] ? worker_thread+0xcc/0x=
183
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c10292ab>] ? process_scheduled_wor=
ks+0x1b/0x1b
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c102c2f7>] ? kthread+0x6a/0x6f
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c102c28d>] ? kthread_data+0xd/0xd
Jun 11 12:53:02 Pleiadi kernel:=A0 [<c11fc996>] ? kernel_thread_helper+=
0x6/0xd
Jun 11 12:53:02 Pleiadi kernel: Mem-Info:
Jun 11 12:53:02 Pleiadi kernel: DMA per-cpu:
Jun 11 12:53:02 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0=A0 0, btch:=A0=
=A0 1 usd:=A0=A0 0
Jun 11 12:53:02 Pleiadi kernel: Normal per-cpu:
Jun 11 12:53:02 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0 42, btch:=A0=A0=
 7 usd:=A0 43
Jun 11 12:53:02 Pleiadi kernel: active_anon:9112 inactive_anon:11797 is=
olated_anon:2
Jun 11 12:53:02 Pleiadi kernel:=A0 active_file:4294 inactive_file:5228 =
isolated_file:14
Jun 11 12:53:02 Pleiadi kernel:=A0 unevictable:0 dirty:152 writeback:15=
 unstable:0
Jun 11 12:53:02 Pleiadi kernel:=A0 free:290 slab_reclaimable:1335 slab_=
unreclaimable:3626
Jun 11 12:53:02 Pleiadi kernel:=A0 mapped:694 shmem:0 pagetables:323 bo=
unce:0
Jun 11 12:53:02 Pleiadi kernel: DMA free:628kB min:156kB low:192kB high=
:232kB active_anon:804kB inactive_anon:7148kB active_file:1724kB inacti=
ve_file:2692kB unevictable:0kB isolated(anon):0kB isolated(file):0kB pr=
esent:15804kB mlocked:0kB dirty:4kB writeback:0kB mapped:212kB shmem:0k=
B slab_reclaimable:792kB slab_unreclaimable:1060kB kernel_stack:168kB p=
agetables:36kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:=
0 all_unreclaimable? no
Jun 11 12:53:02 Pleiadi kernel: lowmem_reserve[]: 0 142 142
Jun 11 12:53:02 Pleiadi kernel: Normal free:532kB min:1448kB low:1808kB=
 high:2172kB active_anon:35644kB inactive_anon:40040kB active_file:1545=
2kB inactive_file:18220kB unevictable:0kB isolated(anon):8kB isolated(f=
ile):56kB present:146304kB mlocked:0kB dirty:604kB writeback:60kB mappe=
d:2564kB shmem:0kB slab_reclaimable:4548kB slab_unreclaimable:13444kB k=
ernel_stack:688kB pagetables:1256kB unstable:0kB bounce:0kB writeback_t=
mp:0kB pages_scanned:0 all_unreclaimable? no
Jun 11 12:53:02 Pleiadi kernel: lowmem_reserve[]: 0 0 0
Jun 11 12:53:02 Pleiadi kernel: DMA: 1*4kB 0*8kB 1*16kB 3*32kB 2*64kB 1=
*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 628kB
Jun 11 12:53:02 Pleiadi kernel: Normal: 77*4kB 28*8kB 0*16kB 0*32kB 0*6=
4kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 532kB
Jun 11 12:53:02 Pleiadi kernel: 12854 total pagecache pages
Jun 11 12:53:02 Pleiadi kernel: 3325 pages in swap cache
Jun 11 12:53:02 Pleiadi kernel: Swap cache stats: add 418409, delete 41=
5084, find 240218/313268
Jun 11 12:53:02 Pleiadi kernel: Free swap=A0 =3D 130908kB
Jun 11 12:53:02 Pleiadi kernel: Total swap =3D 151164kB
Jun 11 12:53:02 Pleiadi kernel: 40944 pages RAM
Jun 11 12:53:02 Pleiadi kernel: 1225 pages reserved
Jun 11 12:53:02 Pleiadi kernel: 12195 pages shared
Jun 11 12:53:02 Pleiadi kernel: 31896 pages non-shared
Jun 11 12:53:02 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
Jun 11 12:53:02 Pleiadi kernel:=A0=A0 cache: kmalloc-2048, object size:=
 2048, buffer size: 2048, default order: 2, min order: 0
Jun 11 12:53:02 Pleiadi kernel:=A0=A0 node 0: slabs: 61, objs: 476, fre=
e: 0
Jun 11 12:53:02 Pleiadi kernel: Switching to clocksource pit

I also got this error (unplug power cord necessary):

May 30 09:57:51 Pleiadi kernel:=A0 [<c11fc996>] ? kernel_thread_helper+=
0x6/0xd
May 30 09:57:51 Pleiadi kernel: Mem-Info:
May 30 09:57:51 Pleiadi kernel: DMA per-cpu:
May 30 09:57:51 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0=A0 0, btch:=A0=
=A0 1 usd:=A0=A0 0
May 30 09:57:51 Pleiadi kernel: Normal per-cpu:
May 30 09:57:51 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0 42, btch:=A0=A0=
 7 usd:=A0 41
May 30 09:57:51 Pleiadi kernel: active_anon:10335 inactive_anon:11540 i=
solated_anon:0
May 30 09:57:51 Pleiadi kernel:=A0 active_file:3924 inactive_file:4094 =
isolated_file:0
May 30 09:57:51 Pleiadi kernel:=A0 unevictable:0 dirty:153 writeback:0 =
unstable:0
May 30 09:57:51 Pleiadi kernel:=A0 free:290 slab_reclaimable:1445 slab_=
unreclaimable:3882
May 30 09:57:51 Pleiadi kernel:=A0 mapped:957 shmem:1 pagetables:321 bo=
unce:0
May 30 09:57:51 Pleiadi kernel: DMA free:628kB min:156kB low:192kB high=
:232kB active_anon:2160kB inactive_anon:6808kB active_file:1792kB inact=
ive_file:2324kB unevictable:0kB isolated(anon):0kB isolated(file):0kB p=
resent:15804kB mlocked:0kB dirty:28kB writeback:0kB mapped:212kB shmem:=
0kB slab_reclaimable:444kB slab_unreclaimable:832kB kernel_stack:0kB pa=
getables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0=
 all_unreclaimable? no
May 30 09:57:51 Pleiadi kernel: lowmem_reserve[]: 0 142 142
May 30 09:57:51 Pleiadi kernel: Normal free:532kB min:1448kB low:1808kB=
 high:2172kB active_anon:39180kB inactive_anon:39352kB active_file:1390=
4kB inactive_file:14052kB unevictable:0kB isolated(anon):0kB isolated(f=
ile):0kB present:146304kB mlocked:0kB dirty:584kB writeback:0kB mapped:=
3616kB shmem:4kB slab_reclaimable:5336kB slab_unreclaimable:14696kB ker=
nel_stack:864kB pagetables:1268kB unstable:0kB bounce:0kB writeback_tmp=
:0kB pages_scanned:0 all_unreclaimable? no
May 30 09:57:51 Pleiadi kernel: lowmem_reserve[]: 0 0 0
May 30 09:57:51 Pleiadi kernel: DMA: 1*4kB 0*8kB 1*16kB 1*32kB 5*64kB 0=
*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 628kB
May 30 09:57:51 Pleiadi kernel: Normal: 1*4kB 0*8kB 1*16kB 0*32kB 2*64k=
B 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 532kB
May 30 09:57:51 Pleiadi kernel: 10792 total pagecache pages
May 30 09:57:51 Pleiadi kernel: 2773 pages in swap cache
May 30 09:57:51 Pleiadi kernel: Swap cache stats: add 284144, delete 28=
1371, find 209552/259249
May 30 09:57:51 Pleiadi kernel: Free swap=A0 =3D 132416kB
May 30 09:57:51 Pleiadi kernel: Total swap =3D 151164kB
May 30 09:57:51 Pleiadi kernel: 40944 pages RAM
May 30 09:57:51 Pleiadi kernel: 1225 pages reserved
May 30 09:57:51 Pleiadi kernel: 11892 pages shared
May 30 09:57:51 Pleiadi kernel: 33496 pages non-shared
May 30 09:57:51 Pleiadi kernel: kworker/0:1: page allocation failure: o=
rder:0, mode:0x20
May 30 09:57:51 Pleiadi kernel: Pid: 16451, comm: kworker/0:1 Not taint=
ed 3.3.5 #1
May 30 09:57:51 Pleiadi kernel: Call Trace:
May 30 09:57:51 Pleiadi kernel:=A0 [<c104eada>] ? warn_alloc_failed+0xb=
7/0xc8
May 30 09:57:51 Pleiadi kernel:=A0 [<c104efbb>] ? __alloc_pages_nodemas=
k+0x4d0/0x4dd
May 30 09:57:51 Pleiadi kernel:=A0 [<c10f88ff>] ? sha1_final+0x62/0x8c
May 30 09:57:51 Pleiadi kernel:=A0 [<c104efd4>] ? __get_free_pages+0xc/=
0x28
May 30 09:57:51 Pleiadi kernel:=A0 [<c10f58ef>] ? blkcipher_walk_next+0=
x69/0x298
May 30 09:57:51 Pleiadi kernel:=A0 [<c10f5c99>] ? blkcipher_walk_first+=
0x159/0x17c
May 30 09:57:51 Pleiadi kernel:=A0 [<c10fc4c8>] ? crypto_cbc_decrypt+0x=
26/0x61
May 30 09:57:51 Pleiadi kernel:=A0 [<c10f7732>] ? shash_ahash_finup+0x4=
c/0x58
May 30 09:57:51 Pleiadi kernel:=A0 [<c10f5e29>] ? async_decrypt+0x40/0x=
46
May 30 09:57:51 Pleiadi kernel:=A0 [<c11013eb>] ? crypto_authenc_decryp=
t+0x6f/0x75
May 30 09:57:51 Pleiadi kernel:=A0 [<c11d99c8>] ? esp_input+0x280/0x29e
May 30 09:57:51 Pleiadi kernel:=A0 [<c11e7150>] ? xfrm_input+0x1b1/0x33=
e
May 30 09:57:51 Pleiadi kernel:=A0 [<c11e0a82>] ? xfrm4_rcv_encap+0x17/=
0x19
May 30 09:57:51 Pleiadi kernel:=A0 [<c11e0c9c>] ? xfrm4_rcv+0x13/0x17
May 30 09:57:51 Pleiadi kernel:=A0 [<c11ac313>] ? ip_local_deliver_fini=
sh+0x116/0x1a4
May 30 09:57:51 Pleiadi kernel:=A0 [<c11ac402>] ? ip_local_deliver+0x61=
/0x67
May 30 09:57:51 Pleiadi kernel:=A0 [<c11ac67a>] ? ip_rcv_finish+0x272/0=
x285
May 30 09:57:51 Pleiadi kernel:=A0 [<c11ac8a8>] ? ip_rcv+0x21b/0x23f
May 30 09:57:51 Pleiadi kernel:=A0 [<c118cd74>] ? __netif_receive_skb+0=
x22e/0x254
May 30 09:57:51 Pleiadi kernel:=A0 [<c118d57f>] ? process_backlog+0x48/=
0xfe
May 30 09:57:51 Pleiadi kernel:=A0 [<c118d7bf>] ? net_rx_action+0x5f/0x=
fb
May 30 09:57:51 Pleiadi kernel:=A0 [<c101f339>] ? __do_softirq+0x59/0xc=
2
May 30 09:57:51 Pleiadi kernel:=A0 [<c101f2e0>] ? local_bh_enable_ip+0x=
77/0x77
May 30 09:57:51 Pleiadi kernel:=A0 <IRQ>=A0 [<c101f25d>] ? local_bh_ena=
ble+0x6b/0x77
May 30 09:57:51 Pleiadi kernel:=A0 [<c1192663>] ? dst_destroy+0x42/0x97
May 30 09:57:51 Pleiadi kernel:=A0 [<c11e27d6>] ? xfrm_bundle_flo_delet=
e+0x1e/0x2c
May 30 09:57:51 Pleiadi kernel:=A0 [<c119975c>] ? flow_entry_kill+0xf/0=
x1c
May 30 09:57:51 Pleiadi kernel:=A0 [<c11997c5>] ? flow_cache_gc_task+0x=
5c/0x65
May 30 09:57:51 Pleiadi kernel:=A0 [<c102919c>] ? process_one_work+0x13=
b/0x22f
May 30 09:57:51 Pleiadi kernel:=A0 [<c1199769>] ? flow_entry_kill+0x1c/=
0x1c
May 30 09:57:51 Pleiadi kernel:=A0 [<c1029377>] ? worker_thread+0xcc/0x=
183
May 30 09:57:51 Pleiadi kernel:=A0 [<c10292ab>] ? process_scheduled_wor=
ks+0x1b/0x1b
May 30 09:57:51 Pleiadi kernel:=A0 [<c102c2f7>] ? kthread+0x6a/0x6f
May 30 09:57:51 Pleiadi kernel:=A0 [<c102c28d>] ? kthread_data+0xd/0xd
May 30 09:57:51 Pleiadi kernel:=A0 [<c11fc996>] ? kernel_thread_helper+=
0x6/0xd
May 30 09:57:51 Pleiadi kernel: Mem-Info:
May 30 09:57:51 Pleiadi kernel: DMA per-cpu:
May 30 09:57:51 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0=A0 0, btch:=A0=
=A0 1 usd:=A0=A0 0
May 30 09:57:51 Pleiadi kernel: Normal per-cpu:
May 30 09:57:51 Pleiadi kernel: CPU=A0=A0=A0 0: hi:=A0=A0 42, btch:=A0=A0=
 7 usd:=A0 41
May 30 09:57:51 Pleiadi kernel: active_anon:10335 inactive_anon:11540 i=
solated_anon:0
May 30 09:57:51 Pleiadi kernel:=A0 active_file:3924 inactive_file:4094 =
isolated_file:0
May 30 09:57:51 Pleiadi kernel:=A0 unevictable:0 dirty:153 writeback:0 =
unstable:0
May 30 09:57:51 Pleiadi kernel:=A0 free:290 slab_reclaimable:1445 slab_=
unreclaimable:3882
May 30 09:57:51 Pleiadi kernel:=A0 mapped:957 shmem:1 pagetables:321 bo=
unce:0
May 30 09:57:51 Pleiadi kernel: DMA free:628kB min:156kB low:192kB high=
:232kB active_anon:2160kB inactive_anon:6808kB active_file:1792kB inact=
ive_file:2324kB unevictable:0kB isolated(anon):0kB isolated(file):0kB p=
resent:15804kB mlocked:0kB dirty:28kB writeback:0kB mapped:212kB shmem:=
0kB slab_reclaimable:444kB slab_unreclaimable:832kB kernel_stack:0kB pa=
getables:16kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0=
 all_unreclaimable? no
May 30 09:57:51 Pleiadi kernel: lowmem_reserve[]: 0 142 142
May 30 09:57:51 Pleiadi kernel: Normal free:532kB min:1448kB low:1808kB=
 high:2172kB active_anon:39180kB inactive_anon:39352kB active_file:1390=
4kB inactive_file:14052kB unevictable:0kB isolated(anon):0kB isolated(f=
ile):0kB present:146304kB mlocked:0kB dirty:584kB writeback:0kB mapped:=
3616kB shmem:4kB slab_reclaimable:5336kB slab_unreclaimable:14696kB ker=
nel_stack:864kB pagetables:1268kB unstable:0kB bounce:0kB writeback_tmp=
:0kB pages_scanned:0 all_unreclaimable? no
May 30 09:57:51 Pleiadi kernel: lowmem_reserve[]: 0 0 0
May 30 09:57:51 Pleiadi kernel: DMA: 1*4kB 0*8kB 1*16kB 1*32kB 5*64kB 0=
*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 628kB
May 30 09:57:51 Pleiadi kernel: Normal: 1*4kB 0*8kB 1*16kB 0*32kB 2*64k=
B 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 532kB
May 30 09:57:51 Pleiadi kernel: 10792 total pagecache pages
May 30 09:57:51 Pleiadi kernel: 2773 pages in swap cache
May 30 09:57:51 Pleiadi kernel: Swap cache stats: add 284144, delete 28=
1371, find 209552/259249
May 30 09:57:51 Pleiadi kernel: Free swap=A0 =3D 132416kB
May 30 09:57:51 Pleiadi kernel: Total swap =3D 151164kB
May 30 09:57:51 Pleiadi kernel: 40944 pages RAM
May 30 09:57:51 Pleiadi kernel: 1225 pages reserved
May 30 09:57:51 Pleiadi kernel: 11892 pages shared
May 30 09:57:51 Pleiadi kernel: 33496 pages non-shared
May 30 09:57:51 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
May 30 09:57:51 Pleiadi kernel:=A0=A0 cache: vm_area_struct, object siz=
e: 84, buffer size: 88, default order: 0, min order: 0
May 30 09:57:51 Pleiadi kernel:=A0=A0 node 0: slabs: 306, objs: 14076, =
free: 0
May 30 09:57:51 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
May 30 09:57:51 Pleiadi kernel:=A0=A0 cache: vm_area_struct, object siz=
e: 84, buffer size: 88, default order: 0, min order: 0
May 30 09:57:51 Pleiadi kernel:=A0=A0 node 0: slabs: 306, objs: 14076, =
free: 0
May 30 09:57:51 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
May 30 09:57:51 Pleiadi kernel:=A0=A0 cache: kmalloc-256, object size: =
256, buffer size: 256, default order: 0, min order: 0
May 30 09:57:51 Pleiadi kernel:=A0=A0 node 0: slabs: 444, objs: 7104, f=
ree: 0
May 30 09:57:51 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
May 30 09:57:51 Pleiadi kernel:=A0=A0 cache: vm_area_struct, object siz=
e: 84, buffer size: 88, default order: 0, min order: 0
May 30 09:57:51 Pleiadi kernel:=A0=A0 node 0: slabs: 306, objs: 14076, =
free: 0
May 30 09:57:51 Pleiadi kernel: SLUB: Unable to allocate memory on node=
 -1 (gfp=3D0x20)
May 30 09:57:51 Pleiadi kernel:=A0=A0 cache: vm_area_struct, object siz=
e: 84, buffer size: 88, default order: 0, min order: 0
May 30 09:57:51 Pleiadi kernel:=A0=A0 node 0: slabs: 306, objs: 14076, =
free: 0
May 30 10:02:22 Pleiadi kernel: klogd 1.4.1, log source =3D /proc/kmsg =
started.


 		 	   		  