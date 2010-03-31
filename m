From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 13:21:42 +0300
Message-ID: <20100331102142.GA3294@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Neil Horman <nhorman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,
I have the following problem:

[  296.337510] ------------[ cut here ]------------
[  296.337523] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc1/0x=
125()
[  296.337527] Hardware name: F3JC               =20
[  296.337530] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[  296.337533] Modules linked in: pktgen ipv6 snd_hwdep snd_hda_codec_si305=
4 snd_hda_codec_realtek sdhci_pci sdhci asus_laptop sparse_keymap mmc_core =
led_class snd_hda_intel
snd_hda_codec psmouse snd_pcm snd_timer snd soundcore snd_page_alloc serio_=
raw i2c_i801 rng_core evdev sg r8169 mii usbhid hid uhci_hcd ehci_hcd sr_mo=
d cdrom sd_mod usbcore
ata_piix
[  296.337586] Pid: 0, comm: swapper Not tainted 2.6.34-rc3-dbg #74
[  296.337589] Call Trace:
[  296.337597]  [<c102e71f>] warn_slowpath_common+0x65/0x7c
[  296.337603]  [<c126e30c>] ? dev_watchdog+0xc1/0x125
[  296.337608]  [<c102e76a>] warn_slowpath_fmt+0x24/0x27
[  296.337613]  [<c126e30c>] dev_watchdog+0xc1/0x125
[  296.337620]  [<c1040039>] ? prepare_to_wait_exclusive+0x52/0x5b
[  296.337627]  [<c1037053>] ? run_timer_softirq+0x120/0x1eb
[  296.337632]  [<c10370a9>] run_timer_softirq+0x176/0x1eb
[  296.337637]  [<c1037053>] ? run_timer_softirq+0x120/0x1eb
[  296.337643]  [<c126e24b>] ? dev_watchdog+0x0/0x125
[  296.337650]  [<c10331c9>] __do_softirq+0x8d/0x117
[  296.337655]  [<c103327e>] do_softirq+0x2b/0x43
[  296.337660]  [<c10333a3>] irq_exit+0x38/0x75
[  296.337667]  [<c1015138>] smp_apic_timer_interrupt+0x6d/0x7b
[  296.337673]  [<c12cbada>] apic_timer_interrupt+0x36/0x3c
[  296.337679]  [<c104007b>] ? prepare_to_wait+0x39/0x57
[  296.337685]  [<c11dd835>] ? acpi_idle_enter_simple+0x119/0x144
[  296.337692]  [<c124d358>] cpuidle_idle_call+0x6d/0xa5
[  296.337697]  [<c1001b51>] cpu_idle+0x92/0xc1
[  296.337704]  [<c12c63d0>] start_secondary+0x1f3/0x1fa
[  296.337708] ---[ end trace cd4a1b50139837df ]---


Reproducing 100% with pktgen tests.


	Sergey
--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuzIjYACgkQfKHnntdSXjS2/AP+PHupP2NnzZsfU8bY+hFoy20+
vYJboanObqL61qlx20DlbhJzpSn162lH6Vb95OfdlmwEFIKo8lXdPBGWChVpHPCa
ILCV+6f6Ba0FXII/Y12Z/MvG5TzRZxCaj7hWSy6XKvi0kRU22lM3FqeIUsm93e0i
//pbHjiEhKQorFzzV44=
=y3A6
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
