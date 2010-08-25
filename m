From: =?UTF-8?B?TmlraGlsIFNldGhpICjgpKjgpL/gpJbgpL/gpLIg4KS44KWH4KSg4KWAKQ==?=
	<nikhil@sethi.ws>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Wed, 25 Aug 2010 13:25:40 -0700
Message-ID: <AANLkTimf5iZV2ytoymCXJ=B2Vgowr6qb6u2nBg+RtBUg@mail.gmail.com>
References: <20100604092025.GA96690@trillian.comsick.at> <1275656014.2482.169.camel@edumazet-laptop>
 <20100604161644.GA98048@trillian.local> <20100606095640.GA4436@trillian.comsick.at>
 <1275820945.5238.987.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Guntsche <mike@it-loops.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275820945.5238.987.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I am running 2.5.35.3 with the above patch, and I still get these
failures. Though they are much less often than without the patch. A
snippet from dmesg below.

Please let me know what other details I should provide. Thanks

skbuff alloc of size 3872 failed
java: page allocation failure. order:1, mode:0x4020
Pid: 11464, comm: java Not tainted 2.6.35.3 #3
Call Trace:
 [<c0243d26>] ? __alloc_pages_nodemask+0x3e6/0x513
 [<c025c293>] ? __slab_alloc+0x2d7/0x2eb
 [<c025c946>] ? __kmalloc_track_caller+0x74/0x95
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<c0334097>] ? __alloc_skb+0x57/0x100
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d0af4100>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
 [<d0cbc89f>] ? br_handle_frame+0x1b3/0x1c3 [bridge]
 [<c033d18a>] ? __netif_receive_skb+0x141/0x25f
 [<d0af23c1>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
 [<c02195bf>] ? tasklet_action+0x5f/0x65
 [<c0219873>] ? __do_softirq+0x60/0xc6
 [<c0219907>] ? do_softirq+0x2e/0x30
 [<c02199f9>] ? irq_exit+0x53/0x55
 [<c020392c>] ? do_IRQ+0x3a/0x72
 [<c0202be9>] ? common_interrupt+0x29/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  32
active_anon:6158 inactive_anon:15748 isolated_anon:0
 active_file:11477 inactive_file:22926 isolated_file:0
 unevictable:468 dirty:5788 writeback:0 unstable:0
 free:990 slab_reclaimable:3091 slab_unreclaimable:2349
 mapped:1410 shmem:5 pagetables:227 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:1304kB
inactive_anon:2304kB active_file:2584kB inactive_file:4900kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB
mlocked:0kB dirty:0kB writeback:0kB mapped:284kB shmem:0kB
slab_reclaimable:648kB slab_unreclaimable:752kB kernel_stack:152kB
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2960kB min:1908kB low:2384kB high:2860kB
active_anon:23328kB inactive_anon:60688kB active_file:43324kB
inactive_file:86804kB unevictable:1872kB isolated(anon):0kB
isolated(file):0kB present:243840kB mlocked:1872kB dirty:23152kB
writeback:0kB mapped:5356kB shmem:20kB slab_reclaimable:11716kB
slab_unreclaimable:8644kB kernel_stack:888kB pagetables:908kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 76*4kB 29*8kB 5*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 1000kB
Normal: 650*4kB 9*8kB 2*16kB 8*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 2960kB
37964 total pagecache pages
3160 pages in swap cache
Swap cache stats: add 164954, delete 161794, find 97931/115609
=46ree swap  =3D 937284kB
Total swap =3D 963896kB
65535 pages RAM
1237 pages reserved
29042 pages shared
38802 pages non-shared
SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
  cache: kmalloc-8192, object size: 8192, buffer size: 8192, default
order: 3, min order: 1
  node 0: slabs: 0, objs: 0, free: 0
skbuff alloc of size 3872 failed
java: page allocation failure. order:1, mode:0x4020
Pid: 11464, comm: java Not tainted 2.6.35.3 #3
Call Trace:
 [<c0243d26>] ? __alloc_pages_nodemask+0x3e6/0x513
 [<c025c293>] ? __slab_alloc+0x2d7/0x2eb
 [<c025c946>] ? __kmalloc_track_caller+0x74/0x95
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<c0334097>] ? __alloc_skb+0x57/0x100
 [<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d0af4100>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
 [<d0cbc89f>] ? br_handle_frame+0x1b3/0x1c3 [bridge]
 [<c033d18a>] ? __netif_receive_skb+0x141/0x25f
 [<d0af23c1>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
 [<c02195bf>] ? tasklet_action+0x5f/0x65
 [<c0219873>] ? __do_softirq+0x60/0xc6
 [<c0219907>] ? do_softirq+0x2e/0x30
 [<c02199f9>] ? irq_exit+0x53/0x55
 [<c020392c>] ? do_IRQ+0x3a/0x72
 [<c0202be9>] ? common_interrupt+0x29/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  32
active_anon:6158 inactive_anon:15748 isolated_anon:0
 active_file:11477 inactive_file:22926 isolated_file:0
 unevictable:468 dirty:5788 writeback:0 unstable:0
 free:990 slab_reclaimable:3091 slab_unreclaimable:2349
 mapped:1410 shmem:5 pagetables:227 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:1304kB
inactive_anon:2304kB active_file:2584kB inactive_file:4900kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB
mlocked:0kB dirty:0kB writeback:0kB mapped:284kB shmem:0kB
slab_reclaimable:648kB slab_unreclaimable:752kB kernel_stack:152kB
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2960kB min:1908kB low:2384kB high:2860kB
active_anon:23328kB inactive_anon:60688kB active_file:43324kB
inactive_file:86804kB unevictable:1872kB isolated(anon):0kB
isolated(file):0kB present:243840kB mlocked:1872kB dirty:23152kB
writeback:0kB mapped:5356kB shmem:20kB slab_reclaimable:11716kB
slab_unreclaimable:8644kB kernel_stack:888kB pagetables:908kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 76*4kB 29*8kB 5*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 1000kB
Normal: 650*4kB 9*8kB 2*16kB 8*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 2960kB
37964 total pagecache pages
3160 pages in swap cache

On Sun, Jun 6, 2010 at 3:42 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> Le dimanche 06 juin 2010 =E0 11:56 +0200, Michael Guntsche a =E9crit =
:
> > On 2010.06.04 18:16:44 , Michael Guntsche wrote:
> > > I applied the patch recompiled and run it on the routerboard, try=
ing
> > > to trigger the bug again.
> >
> > Hi Eric,
> >
> > Up to now I was not able to reproduce the bug, do you think this pa=
tch
> > can be pushed to mainline or is there a "better"/other =A0fix for i=
t?
> >
> > Kind regards,
> > Michael
> >
> >
>
> Thanks Michael for testing.
>
> I'll submit ASAP an official patch, sent to all people involved in th=
is
> driver to get their Ack (or Nack).
>
> IEEE80211_MAX_MPDU_LEN being 3840 + somebits is suspect, since it doe=
snt
> match 802.11 specs.
>
> It should be more close of 2304 + MAC header (32bytes) + FCS (4 bytes=
) ?
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
>
