From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Wed, 17 Mar 2010 08:37:17 +0100
Message-ID: <1268811437.2932.66.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
	 <1268686865.2824.4.camel@edumazet-laptop>
	 <1268699602.2824.14.camel@edumazet-laptop>
	 <20100316145914.GB3332@swordfish.minsk.epam.com>
	 <1268751933.3094.45.camel@edumazet-laptop>
	 <20100316151023.GC3332@swordfish.minsk.epam.com>
	 <1268752826.3094.48.camel@edumazet-laptop>
	 <20100316182619.GA3451@swordfish>
	 <1268765284.2932.17.camel@edumazet-laptop>
	 <20100317072539.GA3579@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:52836 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab0CQHhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 03:37:23 -0400
Received: by bwz3 with SMTP id 3so862655bwz.29
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 00:37:21 -0700 (PDT)
In-Reply-To: <20100317072539.GA3579@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

trimming some cc

Le mercredi 17 mars 2010 =C3=A0 09:25 +0200, Sergey Senozhatsky a =C3=A9=
crit :
> Hello,
>=20
> cumulative patch:
>=20
> [  155.337373] ------------[ cut here ]------------
> [  155.337386] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0=
xc1/0x125()
> [  155.337390] Hardware name: F3JC               =20
> [  155.337394] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed =
out
> [  155.337397] Modules linked in: pktgen ppp_async crc_ccitt ipv6 ppp=
_generic slhc snd_hwdep snd_hda_codec_si3054 snd_hda_codec_realtek sdhc=
i_pci sdhci snd_hda_intel snd_hda_codec
> asus_laptop sparse_keymap mmc_core led_class snd_pcm snd_timer snd_pa=
ge_alloc psmouse rng_core snd soundcore sg i2c_i801 evdev serio_raw r81=
69 mii usbhid hid uhci_hcd ehci_hcd
> sr_mod cdrom sd_mod usbcore ata_piix
> [  155.337468] Pid: 7, comm: ksoftirqd/1 Tainted: G        W  2.6.34-=
rc1-dbg-git6-r8169 #47
> [  155.337472] Call Trace:
> [  155.337481]  [<c102e293>] warn_slowpath_common+0x65/0x7c
> [  155.337506]  [<c126ac34>] ? dev_watchdog+0xc1/0x125
> [  155.337512]  [<c102e2de>] warn_slowpath_fmt+0x24/0x27
> [  155.337517]  [<c126ac34>] dev_watchdog+0xc1/0x125
> [  155.337525]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
> [  155.337530]  [<c1036b51>] run_timer_softirq+0x176/0x1eb
> [  155.337536]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
> [  155.337566]  [<c126ab73>] ? dev_watchdog+0x0/0x125
> [  155.337576]  [<c1032d39>] __do_softirq+0x8d/0x117
> [  155.337667]  [<c1032dee>] do_softirq+0x2b/0x43
> [  155.337729]  [<c1032fc1>] run_ksoftirqd+0x71/0x140
> [  155.337745]  [<c1032f50>] ? run_ksoftirqd+0x0/0x140
> [  155.337810]  [<c103f60e>] kthread+0x6a/0x6f
> [  155.337832]  [<c103f5a4>] ? kthread+0x0/0x6f
> [  155.337903]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
> [  155.337907] ---[ end trace a22d306b065d4a68 ]---
> [  155.350902] r8169 0000:02:00.0: eth0: link up
> [  167.350892] r8169 0000:02:00.0: eth0: link up
>=20
>=20
>=20

On receiver ?

I suspect lot of work is needed on this driver to make it working, but =
I
dont have a machine with said adapter.

Are you in 100 Mb full duplex mode ?


