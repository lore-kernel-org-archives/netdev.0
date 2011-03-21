From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 18:39:41 +0100
Message-ID: <20110321173941.GB3892@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <20110321125320.GA23490@elte.hu>
 <1300714346.2884.284.camel@edumazet-laptop>
 <20110321161528.GA28580@elte.hu>
 <20110321164238.GA5303@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110321164238.GA5303@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


here's the same but with kallsyms enabled.

Thanks,

	Ingo

[    9.585627] initcall 0xffffffff81d5b806 returned 0 after 0 usecs
[    9.588960] calling  0xffffffff81d5b9da @ 1
[    9.592303] IPVS: Creating netns size=3D1272 id=3D0
[    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu.
[    9.602298] IPVS: cannot register namespace.
[    9.605627] IPVS: can't setup control.
[    9.615628] initcall 0xffffffff81d5b9da returned -12 after 22784 use=
cs
[    9.618960] initcall 0xffffffff81d5b9da returned with error code -12=
=20
[    9.622291] calling  0xffffffff81d5c0c0 @ 1
[    9.625625] IPVS: [wlc] scheduler registered.
[    9.628957] initcall 0xffffffff81d5c0c0 returned 0 after 3254 usecs
[    9.632291] calling  0xffffffff81d5c12b @ 1
[    9.635635] IPVS: [lblc] scheduler registered.
[    9.638957] initcall 0xffffffff81d5c12b returned 0 after 3254 usecs
[    9.642290] calling  0xffffffff81d5c167 @ 1
[    9.645623] IPVS: [dh] scheduler registered.
[    9.648956] initcall 0xffffffff81d5c167 returned 0 after 3254 usecs
[    9.652289] calling  0xffffffff81d5c179 @ 1
[    9.655622] IPVS: [sh] scheduler registered.
[    9.658955] initcall 0xffffffff81d5c179 returned 0 after 3254 usecs
[    9.662289] calling  0xffffffff81d5c18b @ 1
[    9.668955] IPVS: [nq] scheduler registered.
[    9.672288] initcall 0xffffffff81d5c18b returned 0 after 3254 usecs
[    9.676859] calling  0xffffffff81d5d589 @ 1
[    9.679217] initcall 0xffffffff81d5d589 returned 0 after 0 usecs
[    9.682288] calling  0xffffffff81d5d9fa @ 1
[    9.685620] IPv4 over IPv4 tunneling driver
[    9.689135] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    9.692285] BUG kmalloc-2048: Poison overwritten
[    9.692285] --------------------------------------------------------=
---------------------
[    9.692285]=20
[    9.692285] INFO: 0xffff88003cc2d6c0-0xffff88003cc2d6d7. First byte =
0x0 instead of 0x6b
[    9.692285] INFO: Allocated in 0xffffffff8178ad5c age=3D29 cpu=3D0 p=
id=3D1
[    9.692285] INFO: Freed in 0xffffffff8178ac6c age=3D23 cpu=3D0 pid=3D=
1
[    9.692285] INFO: Slab 0xffffea0000d4a8c0 objects=3D15 used=3D11 fp=3D=
0xffff88003cc2d2d0 flags=3D0x40000000000040c0
[    9.692285] INFO: Object 0xffff88003cc2d2d0 @offset=3D21200 fp=3D0xf=
fff88003cc2e360
[    9.692285]=20
[    9.692285] Bytes b4 0xffff88003cc2d2c0:  00 00 00 00 00 00 00 00 5a=
 5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
[    9.692285]   Object 0xffff88003cc2d2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d2e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d2f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d300:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d310:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d320:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d330:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d340:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d350:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d360:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d370:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d380:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d390:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d3f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d400:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d410:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d420:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d430:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d440:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d450:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d460:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d470:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d480:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d490:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d4f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d500:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d510:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d520:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d530:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d540:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d550:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d560:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d570:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d580:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d590:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d5f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d600:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d610:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d620:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d630:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d640:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d650:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d660:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d670:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d680:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d690:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d6a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d6b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d6c0:  00 82 8b 01 6b 6b 6b 6b 48=
 82 cb 3c 00 88 ff ff ....kkkkH.=EF=BF=BD<..=EF=BF=BD=EF=BF=BD
[    9.692285]   Object 0xffff88003cc2d6d0:  60 ae d0 81 ff ff ff ff 6b=
 6b 6b 6b 6b 6b 6b 6b `=EF=BF=BD=EF=BF=BD.=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BDkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d6e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d6f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d700:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d710:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d720:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d730:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d740:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d750:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d760:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d770:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d780:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d790:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d7f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d800:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d810:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d820:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d830:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d840:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d850:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d860:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d870:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d880:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d890:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d8f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d900:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d910:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d920:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d930:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d940:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d950:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d960:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d970:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d980:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d990:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2d9f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da00:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da10:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da20:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da30:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da40:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da50:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da60:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da70:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da80:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2da90:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2daa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2dab0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[    9.692285]   Object 0xffff88003cc2dac0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=EF=BF=BD
[    9.692285]  Redzone 0xffff88003cc2dad0:  bb bb bb bb bb bb bb bb   =
                      =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD       =20
[    9.692285]  Padding 0xffff88003cc2db10:  5a 5a 5a 5a 5a 5a 5a 5a   =
                      ZZZZZZZZ       =20
[    9.692285] Pid: 1, comm: swapper Not tainted 2.6.38-tip-08708-g9ad1=
933-dirty #109455
[    9.692285] Call Trace:
[    9.692285]  [<ffffffff810c3c3c>] 0xffffffff810c3c3c
[    9.692285]  [<ffffffff810c3f0f>] 0xffffffff810c3f0f
[    9.692285]  [<ffffffff81798fbb>] ? 0xffffffff81798fbb
[    9.692285]  [<ffffffff810c400c>] 0xffffffff810c400c
[    9.692285]  [<ffffffff81798f31>] ? 0xffffffff81798f31
[    9.692285]  [<ffffffff81798f31>] ? 0xffffffff81798f31
[    9.692285]  [<ffffffff81798f31>] ? 0xffffffff81798f31
[    9.692285]  [<ffffffff8193dbb7>] 0xffffffff8193dbb7
[    9.692285]  [<ffffffff8193e253>] 0xffffffff8193e253
[    9.692285]  [<ffffffff810c63bd>] 0xffffffff810c63bd
[    9.692285]  [<ffffffff81798f31>] ? 0xffffffff81798f31
[    9.692285]  [<ffffffff810aba3e>] 0xffffffff810aba3e
[    9.692285]  [<ffffffff81798f31>] 0xffffffff81798f31
[    9.692285]  [<ffffffff81821593>] 0xffffffff81821593
[    9.692285]  [<ffffffff81821675>] 0xffffffff81821675
[    9.692285]  [<ffffffff81821d40>] 0xffffffff81821d40
[    9.692285]  [<ffffffff8136ad34>] ? 0xffffffff8136ad34
[    9.692285]  [<ffffffff81072568>] 0xffffffff81072568
[    9.692285]  [<ffffffff81072832>] 0xffffffff81072832
[    9.692285]  [<ffffffff8178c87b>] 0xffffffff8178c87b
[    9.692285]  [<ffffffff817913db>] 0xffffffff817913db
[    9.692285]  [<ffffffff8179147e>] 0xffffffff8179147e
[    9.692285]  [<ffffffff81d5d9d8>] 0xffffffff81d5d9d8
[    9.692285]  [<ffffffff8178ae06>] 0xffffffff8178ae06
[    9.692285]  [<ffffffff81d5d9fa>] ? 0xffffffff81d5d9fa
[    9.692285]  [<ffffffff81d5d9fa>] ? 0xffffffff81d5d9fa
[    9.692285]  [<ffffffff8178ae65>] 0xffffffff8178ae65
[    9.692285]  [<ffffffff8194c949>] ? 0xffffffff8194c949
[    9.692285]  [<ffffffff8178af96>] 0xffffffff8178af96
[    9.692285]  [<ffffffff81d5da1b>] 0xffffffff81d5da1b
[    9.692285]  [<ffffffff81d25aee>] 0xffffffff81d25aee
[    9.692285]  [<ffffffff81d25c76>] 0xffffffff81d25c76
[    9.692285]  [<ffffffff8194ea44>] 0xffffffff8194ea44
[    9.692285]  [<ffffffff81d25bcf>] ? 0xffffffff81d25bcf
[    9.692285]  [<ffffffff8194ea40>] ? 0xffffffff8194ea40
[    9.692285] FIX kmalloc-2048: Restoring 0xffff88003cc2d6c0-0xffff880=
03cc2d6d7=3D0x6b
[    9.692285]=20
[    9.692285] FIX kmalloc-2048: Marking all objects used
[    9.692586] initcall 0xffffffff81d5d9fa returned 0 after 6509 usecs
[    9.695620] calling  0xffffffff81d5da59 @ 1
[    9.698952] GRE over IPv4 demultiplexor driver
[    9.702287] initcall 0xffffffff81d5da59 returned 0 after 3254 usecs
[    9.705619] calling  0xffffffff81d5da99 @ 1
[    9.708953] initcall 0xffffffff81d5da99 returned 0 after 0 usecs
[    9.712285] calling  0xffffffff81d5db01 @ 1
[    9.715619] initcall 0xffffffff81d5db01 returned 0 after 0 usecs
[    9.718951] calling  0xffffffff81d5db33 @ 1
[    9.722285] initcall 0xffffffff81d5db33 returned 0 after 0 usecs
[    9.725618] calling  0xffffffff81d5db4a @ 1
[    9.728951] initcall 0xffffffff81d5db4a returned 0 after 0 usecs
[    9.732284] calling  0xffffffff8183391a @ 1
[    9.735618] initcall 0xffffffff8183391a returned 0 after 0 usecs
[    9.738950] calling  0xffffffff81d5f616 @ 1
[    9.742383] initcall 0xffffffff81d5f616 returned 0 after 0 usecs
[    9.745616] calling  0xffffffff81d5f777 @ 1
[    9.748986] initcall 0xffffffff81d5f777 returned 0 after 0 usecs
[    9.752283] calling  0xffffffff81d5f895 @ 1
[    9.755616] initcall 0xffffffff81d5f895 returned 0 after 0 usecs
[    9.758949] calling  0xffffffff81d5f8ac @ 1
[    9.762283] initcall 0xffffffff81d5f8ac returned 0 after 0 usecs
[    9.765615] calling  0xffffffff81d5f8be @ 1
[    9.768948] initcall 0xffffffff81d5f8be returned 0 after 0 usecs
[    9.772281] calling  0xffffffff81d5f8e0 @ 1
[    9.775634] ip_tables: (C) 2000-2006 Netfilter Core Team
[    9.778948] initcall 0xffffffff81d5f8e0 returned 0 after 3254 usecs
[    9.782281] calling  0xffffffff81d5f9e6 @ 1
[    9.785650] initcall 0xffffffff81d5f9e6 returned 0 after 0 usecs
[    9.788947] calling  0xffffffff81d5faee @ 1
[    9.792304] initcall 0xffffffff81d5faee returned 0 after 0 usecs
[    9.795613] calling  0xffffffff81d5fbc7 @ 1
[    9.798970] initcall 0xffffffff81d5fbc7 returned 0 after 0 usecs
[    9.802280] calling  0xffffffff81d5fc15 @ 1
[    9.805613] initcall 0xffffffff81d5fc15 returned 0 after 0 usecs
[    9.808946] calling  0xffffffff81d5fc27 @ 1
[    9.812285] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[    9.815612] initcall 0xffffffff81d5fc27 returned 0 after 3254 usecs
[    9.818945] calling  0xffffffff81d5fcba @ 1
[    9.822281] initcall 0xffffffff81d5fcba returned 0 after 0 usecs
[    9.825611] calling  0xffffffff81d5fcf2 @ 1
[    9.828967] initcall 0xffffffff81d5fcf2 returned 0 after 0 usecs
[    9.832278] calling  0xffffffff81d5fd67 @ 1
[    9.835611] initcall 0xffffffff81d5fd67 returned 0 after 0 usecs
[    9.838944] calling  0xffffffff81d5fd79 @ 1
[    9.842278] TCP westwood registered
[    9.845610] initcall 0xffffffff81d5fd79 returned 0 after 3254 usecs
