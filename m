From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 18 Mar 2010 14:28:39 +0200
Message-ID: <20100318122839.GB3364@swordfish.minsk.epam.com>
References: <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100317072539.GA3579@swordfish>
 <1268811437.2932.66.camel@edumazet-laptop>
 <20100317105856.GB3322@swordfish>
 <1268834068.2899.336.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y7xTucakfITjPcLV"
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:49521 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab0CRM1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 08:27:45 -0400
Received: by fxm19 with SMTP id 19so2045894fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 05:27:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1268834068.2899.336.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Y7xTucakfITjPcLV
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On (03/17/10 14:54), Eric Dumazet wrote:
> Le mercredi 17 mars 2010 =C3=A0 12:58 +0200, Sergey Senozhatsky a =C3=A9c=
rit :
> > Hello,
> >=20
> > We did pktgen over LAN testing for several hours:
> >=20
> > iftop
> >                        19.1Mb                 38.1Mb                  5=
7.2Mb                 76.3Mb            95.4Mb
> > =E2=94=94=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=B4=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=B4=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=B4=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=B4=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80
> > xxxxxxxx0007t2                               =3D> xxxxxxxxxxxxxx.xxxxx.=
xxxx.xxx                    0b   3.60Kb  4.28Kb
> >                                              <=3D                      =
                         92.7Mb  92.7Mb  92.5Mb
> >=20
> > =E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=
=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=
=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=E2=94=80=
=E2=94=80
> > TX:             cumm:  2.50MB   peak:   57.7Kb                         =
              rates:   7.71Kb  5.97Kb  10.7Kb
> > RX:                    28.0GB           92.9Mb                         =
                       92.7Mb  92.8Mb  92.6Mb
> > TOTAL:                 28.0GB           92.9Mb                         =
                       92.7Mb  92.8Mb  92.6M
> >=20
> > Without any problems.
> >=20
> >=20
> > As soon as I switched back to localhost "pollution":
> >=20
> > [ 7343.999279] ------------[ cut here ]------------
> > [ 7343.999292] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc=
1/0x125()
> > [ 7343.999295] Hardware name: F3JC               =20
> > [ 7343.999298] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
> > [ 7343.999301] Modules linked in: pktgen ppp_async crc_ccitt ipv6 ppp_g=
eneric slhc snd_hwdep snd_hda_codec_si3054 snd_hda_codec_realtek sdhci_pci =
sdhci snd_hda_intel mmc_core
> > asus_laptop sparse_keymap snd_hda_codec led_class snd_pcm rng_core sg p=
smouse snd_timer snd_page_alloc i2c_i801 evdev snd soundcore serio_raw r816=
9 mii usbhid hid uhci_hcd
> > ehci_hcd sr_mod cdrom sd_mod usbcore ata_piix
> > [ 7343.999361] Pid: 4801, comm: kpktgend_0 Tainted: G        W  2.6.34-=
rc1-dbg-git6-r8169 #47
> > [ 7343.999364] Call Trace:
> > [ 7343.999372]  [<c102e293>] warn_slowpath_common+0x65/0x7c
> > [ 7343.999378]  [<c126ac34>] ? dev_watchdog+0xc1/0x125
> > [ 7343.999383]  [<c102e2de>] warn_slowpath_fmt+0x24/0x27
> > [ 7343.999388]  [<c126ac34>] dev_watchdog+0xc1/0x125
> > [ 7343.999395]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
> > [ 7343.999401]  [<c1036b51>] run_timer_softirq+0x176/0x1eb
> > [ 7343.999406]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
> > [ 7343.999411]  [<c126ab73>] ? dev_watchdog+0x0/0x125
> > [ 7343.999417]  [<c1032d39>] __do_softirq+0x8d/0x117
> > [ 7343.999422]  [<c1032dee>] do_softirq+0x2b/0x43
> > [ 7343.999426]  [<c1032f13>] irq_exit+0x38/0x75
> > [ 7343.999433]  [<c1014e75>] smp_apic_timer_interrupt+0x66/0x74
> > [ 7343.999438]  [<c12c770a>] apic_timer_interrupt+0x36/0x3c
> > [ 7343.999447]  [<f80878df>] ? pktgen_thread_worker+0x5c4/0x631 [pktgen]
> > [ 7343.999454]  [<c103f931>] ? autoremove_wake_function+0x0/0x2f
> > [ 7343.999459]  [<c103f931>] ? autoremove_wake_function+0x0/0x2f
> > [ 7343.999465]  [<f808731b>] ? pktgen_thread_worker+0x0/0x631 [pktgen]
> > [ 7343.999470]  [<c103f60e>] kthread+0x6a/0x6f
> > [ 7343.999476]  [<c103f5a4>] ? kthread+0x0/0x6f
> > [ 7343.999481]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
> > [ 7343.999485] ---[ end trace a22d306b065d4a68 ]---
> > [ 7344.012654] r8169 0000:02:00.0: eth0: link up
> > [ 7356.012657] r8169 0000:02:00.0: eth0: link up
> > [ 7368.013545] r8169 0000:02:00.0: eth0: link up
> >=20
> >=20
>=20
> What do you exactly mean by 'localhost pollution' ?
>=20
Sorry. I mean pktgen started on localhost with src set to localhost (not pk=
tgen over LAN from another machine).


	Sergey

--Y7xTucakfITjPcLV
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuiHHcACgkQfKHnntdSXjShFAQAv4qA3I4vosMBWCTJ8mSLd8Ph
jv8KcC5niuwL1I2B5NB7hbTmxmHBBfQ9HFdE3TjJYSlv6iqX3Gq5+1qdltLvywzz
TtZPgoW2Jc0s/IrIgTHVLnQu2e6mc2pxn69DlWLRzAN+X5Ob+lcrBjxGGlxjacqn
XJAa0rEhiBLjojIr5Ko=
=Qdgt
-----END PGP SIGNATURE-----

--Y7xTucakfITjPcLV--
