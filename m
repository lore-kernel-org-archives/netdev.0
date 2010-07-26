From: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #15704] [r8169] WARNING: at net/sched/sch_generic.c
Date: Mon, 26 Jul 2010 17:57:42 +0300
Message-ID: <20100726145742.GA4888@swordfish.minsk.epam.com>
References: <wQMMFC59mnE.A.v-E.iUYSMB@chimera>
 <PRbv8sgxY6G.A.UEH.mYYSMB@chimera>
 <20100726131629.GA4398@swordfish.minsk.epam.com>
 <1280154873.2899.390.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1280154873.2899.390.camel@edumazet-laptop>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/26/10 16:34), Eric Dumazet wrote:
> > Sorry for the dealy - I've been away.
> > So, the bad news are that this is probably the last time I can test thi=
s bug. This laptop will
> > no longer be available. Sorry.
> >=20
> >=20
> > [ 2599.495508] pktgen 2.73: Packet Generator for packet performance tes=
ting.
> > [ 2630.016019] ------------[ cut here ]------------
> > [ 2630.016031] WARNING: at net/sched/sch_generic.c:258 dev_watchdog+0xc=
1/0x129()
> > [ 2630.016035] Hardware name: F3JC               =20
> > [ 2630.016038] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> > [ 2630.016041] Modules linked in: pktgen ipv6 arc4 ecb iwl3945 snd_hwde=
p iwlcore snd_seq_dummy snd_hda_codec_si3054 snd_hda_codec_realtek snd_seq_=
oss snd_seq_midi_event snd_seq snd_seq_device mac80211 snd_pcm_oss snd_mixe=
r_oss asus_laptop
> > snd_hda_intel sparse_keymap sdhci_pci sdhci mmc_core led_class cfg80211=
 snd_hda_codec snd_pcm snd_timer snd_page_alloc snd rng_core soundcore usb_=
storage sg psmouse evdev i2c_i801 serio_raw r8169 mii uhci_hcd ehci_hcd sd_=
mod sr_mod usbcore
> > cdrom ata_piix
> > [ 2630.016114] Pid: 4282, comm: kpktgend_0 Not tainted 2.6.35-rc6-dbg-g=
it1-00136-g459ab2a-dirty #75
> > [ 2630.016118] Call Trace:
> > [ 2630.016125]  [<c102e3ae>] warn_slowpath_common+0x65/0x7a
> > [ 2630.016131]  [<c12695f3>] ? dev_watchdog+0xc1/0x129
> > [ 2630.016136]  [<c102e427>] warn_slowpath_fmt+0x26/0x2a
> > [ 2630.016142]  [<c12695f3>] dev_watchdog+0xc1/0x129
> > [ 2630.016149]  [<c10370b3>] ? run_timer_softirq+0x136/0x22b
> > [ 2630.016154]  [<c103710c>] run_timer_softirq+0x18f/0x22b
> > [ 2630.016160]  [<c10370b3>] ? run_timer_softirq+0x136/0x22b
> > [ 2630.016165]  [<c1269532>] ? dev_watchdog+0x0/0x129
> > [ 2630.016171]  [<c1032c35>] __do_softirq+0x88/0x10c
> > [ 2630.016177]  [<c1032ce8>] do_softirq+0x2f/0x47
> > [ 2630.016182]  [<c1032fa5>] irq_exit+0x38/0x75
> > [ 2630.016187]  [<c10159b8>] smp_apic_timer_interrupt+0x5f/0x6d
> > [ 2630.016195]  [<f80555e4>] ? pktgen_xmit+0xda2/0xe6f [pktgen]
> > [ 2630.016202]  [<c12c75a2>] apic_timer_interrupt+0x36/0x3c
> > [ 2630.016208]  [<f80555e4>] ? pktgen_xmit+0xda2/0xe6f [pktgen]
> > [ 2630.016214]  [<f80555e4>] ? pktgen_xmit+0xda2/0xe6f [pktgen]
> > [ 2630.016220]  [<c104007b>] ? __kfifo_peek_n+0x13/0x2b
> > [ 2630.016226]  [<c1032edd>] ? _local_bh_enable_ip+0x9d/0xb3
> > [ 2630.016231]  [<c1032efb>] local_bh_enable_ip+0x8/0xa
> > [ 2630.016236]  [<c12c6aaa>] _raw_spin_unlock_bh+0x2f/0x32
> > [ 2630.016242]  [<f80555e4>] pktgen_xmit+0xda2/0xe6f [pktgen]
> > [ 2630.016253]  [<f91707b8>] ? rtl8169_start_xmit+0x0/0x307 [r8169]
> > [ 2630.016261]  [<c11800d8>] ? plist_add+0x85/0x87
> > [ 2630.016267]  [<f80558ac>] ? pktgen_thread_worker+0x96/0x5c3 [pktgen]
> > [ 2630.016273]  [<c1029096>] ? get_parent_ip+0xb/0x31
> > [ 2630.016279]  [<c1029138>] ? sub_preempt_count+0x7c/0x89
> > [ 2630.016285]  [<f8055986>] pktgen_thread_worker+0x170/0x5c3 [pktgen]
> > [ 2630.016290]  [<c12c52bb>] ? schedule+0x535/0x545
> > [ 2630.016296]  [<c103fd96>] ? autoremove_wake_function+0x0/0x2f
> > [ 2630.016301]  [<c103fd96>] ? autoremove_wake_function+0x0/0x2f
> > [ 2630.016307]  [<f8055816>] ? pktgen_thread_worker+0x0/0x5c3 [pktgen]
> > [ 2630.016313]  [<c103faa6>] kthread+0x6a/0x6f
> > [ 2630.016318]  [<c103fa3c>] ? kthread+0x0/0x6f
> > [ 2630.016324]  [<c1002d82>] kernel_thread_helper+0x6/0x10
> > [ 2630.016328] ---[ end trace 0bdadff7f249bd0d ]---
> > [ 2630.032549] r8169 0000:02:00.0: eth0: link up
> >=20
> >=20
> > 	Sergey
>

Hello,
=20
> r8169 driver misses a netif_carrier_off() call somewhere, probably when
> adapter is reset
>=20
> Sergey, do you run a pktgen only test (sending packets, and not
> receiving packets during the test), or a mixed workload ?
>

Only sending.=20

--
 PGDEV=3D/proc/net/pktgen/eth0
 echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"
 pgset "dst 192.168.x.x"
 pgset "dst_mac  x:x:x:x:x:x"

 PGDEV=3D/proc/net/pktgen/pgctrl

 echo "Running..."
 pgset "start"
--

=20
> r8169 is known to reset if the RX ring buffer is stressed too much.
>=20

	Sergey
--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkxNomYACgkQfKHnntdSXjTTPAP/Vay3VAC1RUo/V5ilows6XaG7
F3Uru0Kx2zPrXtoUozd+ycr4zqwFY7OkAd9h+tWl62VulIpmAcVFARDDMPBN3r1l
2yAQbhjfamMW9eAxbZZp22moM5APYc3Zkqr9rLcT6VtUS+vdU42DvH1dI5oWCQ8A
W64M3l4tWfbIreH0yzU=
=VIVk
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
