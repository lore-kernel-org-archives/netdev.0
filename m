From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 17:10:23 +0200
Message-ID: <20100316151023.GC3332@swordfish.minsk.epam.com>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="76DTJ5CE0DCVQemd"
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268751933.3094.45.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--76DTJ5CE0DCVQemd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (03/16/10 16:05), Eric Dumazet wrote:
> > Nope!
> > Here it is:
> >=20
> >=20
> > [17250.998293] ------------[ cut here ]------------
> > [17250.998305] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc=
1/0x125()
> > [17250.998308] Hardware name: F3JC               =20
> > [17250.998312] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> > [17250.998315] Modules linked in: pktgen ppp_async crc_ccitt ipv6 ppp_g=
eneric slhc snd_hwdep snd_hda_codec_si3054 snd_hda_codec_realtek sdhci_pci =
sdhci asus_laptop sparse_keymap
> > mmc_core led_class snd_hda_intel snd_hda_codec snd_pcm snd_timer snd_pa=
ge_alloc rng_core sg evdev i2c_i801 snd soundcore psmouse r8169 serio_raw m=
ii uhci_hcd ehci_hcd sr_mod
> > usbcore cdrom sd_mod ata_piix
> > [17250.998371] Pid: 3985, comm: kpktgend_0 Tainted: G        W  2.6.34-=
rc1-dbg-git6-r8169 #46
> > [17250.998375] Call Trace:
> > [17250.998383]  [<c102e353>] warn_slowpath_common+0x65/0x7c
> > [17250.998388]  [<c126b654>] ? dev_watchdog+0xc1/0x125
> > [17250.998393]  [<c102e39e>] warn_slowpath_fmt+0x24/0x27
> > [17250.998398]  [<c126b654>] dev_watchdog+0xc1/0x125
> > [17250.998405]  [<c1036bbb>] ? run_timer_softirq+0x120/0x1eb
> > [17250.998411]  [<c1036c11>] run_timer_softirq+0x176/0x1eb
> > [17250.998416]  [<c1036bbb>] ? run_timer_softirq+0x120/0x1eb
> > [17250.998421]  [<c126b593>] ? dev_watchdog+0x0/0x125
> > [17250.998426]  [<c1032df9>] __do_softirq+0x8d/0x117
> > [17250.998431]  [<c1032eae>] do_softirq+0x2b/0x43
> > [17250.998436]  [<c1032fd3>] irq_exit+0x38/0x75
> > [17250.998442]  [<c1014e75>] smp_apic_timer_interrupt+0x66/0x74
> > [17250.998448]  [<c12c812a>] apic_timer_interrupt+0x36/0x3c
> > [17250.998457]  [<c1185d18>] ? do_raw_spin_trylock+0x28/0x37
> > [17250.998464]  [<c12c7101>] _raw_spin_lock+0x2f/0x58
> > [17250.998472]  [<f80855ca>] ? spin_lock+0x8/0xa [pktgen]
> > [17250.998478]  [<f80855ca>] spin_lock+0x8/0xa [pktgen]
> > [17250.998484]  [<f80873b6>] pktgen_thread_worker+0x9b/0x631 [pktgen]
> > [17250.998491]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
> > [17250.998497]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
> > [17250.998503]  [<f808731b>] ? pktgen_thread_worker+0x0/0x631 [pktgen]
> > [17250.998508]  [<c103f6ce>] kthread+0x6a/0x6f
> > [17250.998514]  [<c103f664>] ? kthread+0x0/0x6f
> > [17250.998520]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
> > [17250.998523] ---[ end trace a22d306b065d4a68 ]---
> > [17251.011663] r8169 0000:02:00.0: eth0: link up
> >=20
> > [17419.011748] NOHZ: local_softirq_pending 08
> >=20
> >=20
>=20
> But this stack trace is on pktgen side (the sender), and my patch was
> about the receiver ?
>=20

[...]
>> NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Isn't it r8169 related?


> I wonder if you dont hit another problem :)
:)


	Sergey
--76DTJ5CE0DCVQemd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkufn18ACgkQfKHnntdSXjR/hwQAs34v0OSqD1UNDjhSDyyUAvfN
4bxS8ppR6YVjlqw73+DBQLdCyQ9kNRoMxM5Ol6s2MNV2Of1jltQjSZIOwJ+FIyN9
adVFZBlhYri2k0L7mSrDny1rRIPp5UqvXSl1ei0RiR0r7QU8W5Bh6kBfWWIrCvoq
fG3I0uzgS8meeA5/SKw=
=7EMn
-----END PGP SIGNATURE-----

--76DTJ5CE0DCVQemd--
