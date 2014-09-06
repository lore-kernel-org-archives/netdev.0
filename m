From: Jorge Daniel Sequeira Matias <jdsm@tecnico.ulisboa.pt>
Subject: Re: [NS] page allocation failure. order:2, mode:0x204020 while enabling Jumbo frame
Date: Sat, 6 Sep 2014 11:29:46 +0100
Message-ID: <C94032F6-3519-4394-89CB-3BE1417AA410@tecnico.ulisboa.pt>
References: <20140905184400.GA27606@calhariz.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "ns-list@dsi.ist.utl.pt" <ns-list@dsi.ist.utl.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ist.utl.pt ([193.136.128.22]:40204 "EHLO smtp2.ist.utl.pt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbaIFKhC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 06:37:02 -0400
In-Reply-To: <20140905184400.GA27606@calhariz.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bom dia,

=C3=89 pena que o t=C3=ADtulo n=C3=A3o tivesse come=C3=A7ado por "bnx2x=
: ".
N=C3=A3o acredito que este problema seja transversal a todas =C3=A0 as =
placas de rede.
Brevemente teremos oportunidade de testar uma placa diferente, que vai =
sair de uma das brites.

Jorge

Sent from my iPhone

> On 05/09/2014, at 19:44, Jose M Calhariz <jose.calhariz@netvisao.pt> =
wrote:
>=20
>=20
> Hi
>=20
> I have a Debian 7.0 server currently running kernel 3.16 from
> kernel.org.  This server is a client of nfsv3, iSCSI and use dmcrypt.
> When and only when enabling Jumbo Frames I get "page allocation
> failure: order:2, mode:0x204020", in the end of the email is a stack
> trace from this error.
>=20
> Sometimes the rate of "page allocation failure" is very big or the
> network stack stops, making the machine "network unreachable" to a
> nagios server.
>=20
>=20
> Sep  5 10:51:14 XXXXXX kernel: warn_alloc_failed: 5 callbacks suppres=
sed
> Sep  5 10:51:14 XXXXXX kernel: kworker/0:1: page allocation failure: =
order:2, mode:0x204020
> Sep  5 10:51:14 XXXXXX kernel: CPU: 0 PID: 6178 Comm: kworker/0:1 Tai=
nted: G          I   3.16.0-dsi #9
> Sep  5 10:51:14 XXXXXX kernel: Hardware name: Dell Inc. PowerEdge R41=
0/01V648, BIOS 1.12.0 07/30/2013
> Sep  5 10:51:14 XXXXXX kernel: Workqueue: kcryptd kcryptd_crypt [dm_c=
rypt]
> Sep  5 10:51:14 XXXXXX kernel: 0000000000000000 0000000000000000 ffff=
ffff814fd161 0000000000204020
> Sep  5 10:51:14 XXXXXX kernel: ffffffff811395d2 ffff88032fffac00 ffff=
ffff818b04b0 0000000000000003
> Sep  5 10:51:14 XXXXXX kernel: 0000000000000018 000000012fffac18 ffff=
8801affff0a8 0000000000000096
> Sep  5 10:51:14 XXXXXX kernel: Call Trace:
> Sep  5 10:51:14 XXXXXX kernel: <IRQ>  [<ffffffff814fd161>] ? dump_sta=
ck+0x41/0x51
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff811395d2>] ? warn_alloc_fail=
ed+0xf2/0x150
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8113d930>] ? __alloc_pages_n=
odemask+0x8e0/0xb40
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8118355a>] ? kmem_getpages+0=
x5a/0x110
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8118522f>] ? fallback_alloc+=
0x1cf/0x220
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019ef1d>] ? bnx2x_alloc_rx_=
data.isra.75+0x5d/0x1e0 [bnx2x]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff811854bc>] ? __kmalloc+0x19c=
/0x1f0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019ef1d>] ? bnx2x_alloc_rx_=
data.isra.75+0x5d/0x1e0 [bnx2x]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa019f894>] ? bnx2x_rx_int+0x=
7f4/0x1790 [bnx2x]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814005e8>] ? skb_release_hea=
d_state+0x48/0xf0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814006f9>] ? __kfree_skb+0x9=
/0xa0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81461f6d>] ? tcp_schedule_lo=
ss_probe+0x12d/0x1a0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa01a25a8>] ? bnx2x_poll+0xe8=
/0x3b0 [bnx2x]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8140fc18>] ? net_rx_action+0=
x138/0x240
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8106af4f>] ? __do_softirq+0x=
df/0x270
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff8106b315>] ? irq_exit+0x95/0=
xa0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81015701>] ? do_IRQ+0x61/0x1=
10
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81503aed>] ? common_interrup=
t+0x6d/0x6d
> Sep  5 10:51:14 XXXXXX kernel: <EOI>  [<ffffffffa0378c10>] ? _aesni_e=
nc1+0x5c/0xac [aesni_intel]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa0379170>] ? aesni_cbc_enc+0=
x20/0x40 [aesni_intel]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa037ab24>] ? cbc_encrypt+0x7=
4/0xd0 [aesni_intel]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa02270fe>] ? __ablk_encrypt+=
0x3e/0x50 [ablk_helper]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa069641b>] ? crypt_convert+0=
x20b/0x460 [dm_crypt]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffffa069682b>] ? kcryptd_crypt+0=
x1bb/0x400 [dm_crypt]
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81080adb>] ? process_one_wor=
k+0x16b/0x400
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81081184>] ? worker_thread+0=
x114/0x510
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff814ff3f8>] ? __schedule+0x2c=
8/0x760
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81081070>] ? rescuer_thread+=
0x2c0/0x2c0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff810876cc>] ? kthread+0xbc/0x=
e0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81087610>] ? flush_kthread_w=
orker+0x80/0x80
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81502f3c>] ? ret_from_fork+0=
x7c/0xb0
> Sep  5 10:51:14 XXXXXX kernel: [<ffffffff81087610>] ? flush_kthread_w=
orker+0x80/0x80
> Sep  5 10:51:14 XXXXXX kernel: Mem-Info:
> Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal per-cpu:
> Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd: 141
> Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd: 178
> Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd: 169
> Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd: 181
> Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA per-cpu:
> Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:    0, btch:   1 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32 per-cpu:
> Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:  51
> Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd:  36
> Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:  51
> Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:  59
> Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal per-cpu:
> Sep  5 10:51:14 XXXXXX kernel: CPU    0: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    1: hi:  186, btch:  31 usd:  95
> Sep  5 10:51:14 XXXXXX kernel: CPU    2: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    3: hi:  186, btch:  31 usd: 100
> Sep  5 10:51:14 XXXXXX kernel: CPU    4: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    5: hi:  186, btch:  31 usd:  95
> Sep  5 10:51:14 XXXXXX kernel: CPU    6: hi:  186, btch:  31 usd:   0
> Sep  5 10:51:14 XXXXXX kernel: CPU    7: hi:  186, btch:  31 usd:  79
> Sep  5 10:51:14 XXXXXX kernel: active_anon:391978 inactive_anon:21723=
4 isolated_anon:0
> Sep  5 10:51:14 XXXXXX kernel: active_file:405690 inactive_file:25149=
7 isolated_file:0
> Sep  5 10:51:14 XXXXXX kernel: unevictable:2192 dirty:0 writeback:0 u=
nstable:0
> Sep  5 10:51:14 XXXXXX kernel: free:482104 slab_reclaimable:827503 sl=
ab_unreclaimable:171240
> Sep  5 10:51:14 XXXXXX kernel: mapped:3469 shmem:99 pagetables:2164 b=
ounce:0
> Sep  5 10:51:14 XXXXXX kernel: free_cma:0
> Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal free:801464kB min:528080=
kB low:660100kB high:792120kB active_anon:1161624kB inactive_anon:38758=
0kB active_file:534424kB inactive_file:291488kB unevictable:4940kB isol=
ated(anon):0kB isolated(file):0kB present:6291456kB managed:6203092kB m=
locked:4944kB dirty:0kB
> +writeback:0kB mapped:5116kB shmem:124kB slab_reclaimable:1923736kB s=
lab_unreclaimable:386892kB kernel_stack:4368kB pagetables:5768kB unstab=
le:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:47 all_u=
nreclaimable? no
> Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 0 0
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA free:15896kB min:1352kB low=
:1688kB high:2028kB active_anon:0kB inactive_anon:0kB active_file:0kB i=
nactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB =
present:15980kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB map=
ped:0kB shmem:0kB
> +slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetab=
les:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_sc=
anned:0 all_unreclaimable? yes
> Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 3224 5952 5952
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32 free:804396kB min:281328k=
B low:351660kB high:421992kB active_anon:240284kB inactive_anon:288392k=
B active_file:558572kB inactive_file:412684kB unevictable:1972kB isolat=
ed(anon):0kB isolated(file):0kB present:3378660kB managed:3304628kB mlo=
cked:1972kB dirty:0kB writeback:0kB
> +mapped:4144kB shmem:204kB slab_reclaimable:618324kB slab_unreclaimab=
le:133696kB kernel_stack:1168kB pagetables:1512kB unstable:0kB bounce:0=
kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 2727 2727
> Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal free:306660kB min:237808=
kB low:297260kB high:356712kB active_anon:166004kB inactive_anon:192964=
kB active_file:529764kB inactive_file:301816kB unevictable:1856kB isola=
ted(anon):0kB isolated(file):0kB present:2883584kB managed:2793404kB ml=
ocked:1856kB dirty:0kB writeback:0kB
> +mapped:4616kB shmem:68kB slab_reclaimable:767952kB slab_unreclaimabl=
e:164372kB kernel_stack:1312kB pagetables:1376kB unstable:0kB bounce:0k=
B free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> Sep  5 10:51:14 XXXXXX kernel: lowmem_reserve[]: 0 0 0 0
> Sep  5 10:51:14 XXXXXX kernel: Node 0 Normal: 186511*4kB (UEM) 5585*8=
kB (UEM) 421*16kB (UM) 1*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024=
kB 0*2048kB 1*4096kB (R) =3D 801588kB
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA: 0*4kB 1*8kB (U) 1*16kB (U)=
 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048k=
B (R) 3*4096kB (M) =3D 15896kB
> Sep  5 10:51:14 XXXXXX kernel: Node 1 DMA32: 97773*4kB (EM) 49708*8kB=
 (EM) 721*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*204=
8kB 1*4096kB (R) =3D 804388kB
> Sep  5 10:51:14 XXXXXX kernel: Node 1 Normal: 48558*4kB (EM) 13544*8k=
B (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*=
4096kB (R) =3D 306680kB
> Sep  5 10:51:14 XXXXXX kernel: Node 0 hugepages_total=3D0 hugepages_f=
ree=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
> Sep  5 10:51:14 XXXXXX kernel: Node 1 hugepages_total=3D0 hugepages_f=
ree=3D0 hugepages_surp=3D0 hugepages_size=3D2048kB
> Sep  5 10:51:14 XXXXXX kernel: 658273 total pagecache pages
> Sep  5 10:51:14 XXXXXX kernel: 37 pages in swap cache
> Sep  5 10:51:14 XXXXXX kernel: Swap cache stats: add 499, delete 462,=
 find 7/10
> Sep  5 10:51:14 XXXXXX kernel: Free swap  =3D 37456928kB
> Sep  5 10:51:14 XXXXXX kernel: Total swap =3D 37458864kB
> Sep  5 10:51:14 XXXXXX kernel: 3142420 pages RAM
> Sep  5 10:51:14 XXXXXX kernel: 0 pages HighMem/MovableOnly
> Sep  5 10:51:14 XXXXXX kernel: 22545 pages reserved
> Sep  5 10:51:14 XXXXXX kernel: 0 pages hwpoisoned
>=20
>=20
>=20
> --=20
> --
>    Cita=C3=A7=C3=A3o: ato de repetir de modo errado as palavras alhei=
as.
>        --  Ambrose Bierce; jornalista e cientista americano.
> _______________________________________________
> ns-list mailing list
> ns-list@dsi.ist.utl.pt
> https://mlists.ist.utl.pt/mailman/listinfo/groups.ciist.ns-list
