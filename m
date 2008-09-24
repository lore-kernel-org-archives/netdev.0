From: Brett Pemberton <brett@vpac.org>
Subject: forcedeth network hang
Date: Wed, 24 Sep 2008 10:33:00 +1000
Message-ID: <1222216380.4019.253.camel@sys05.in.vpac.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jNhCqOmwp6y7e9Gdg5Y9"
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753387AbYIXAdb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jNhCqOmwp6y7e9Gdg5Y9
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hey,

Had a problem with 13 nodes all halting network traffic at the same time
last night. =20

Although this trace is from 2.6.26.3, a variety of kernels hung,
including 2.6.26.5.

Any help would be great, please CC as am not on lists.

	/ Brett

A sample from /var/log/messages:

Sep 23 17:55:31 tango055 kernel: NETDEV WATCHDOG: eth0: transmit timed
out
Sep 23 17:55:31 tango055 kernel: eth0: Got tx_timeout. irq: 00000000
Sep 23 17:55:31 tango055 kernel: eth0: Ring at 41c5c8000
Sep 23 17:55:31 tango055 kernel: eth0: Dumping tx registers
....
Sep 23 17:55:31 tango055 kernel: ------------[ cut here ]------------
Sep 23 17:55:31 tango055 kernel: WARNING: at net/sched/sch_generic.c:222
dev_watchdog+0xa6/0xfb()
Sep 23 17:55:31 tango055 kernel: Modules linked in: ipmi_devintf ipmi_si
ipmi_msghandler autofs4 nfs lockd nfs_acl sunrpc ipv6 ib_ipoib rdma_ucm
ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_
addr ib_sa xfs dm_mirror dm_log dm_multipath dm_mod sbs sbshc battery
backlight ac ib_mthca ib_mad sg ib_core button serio_raw forcedeth
usb_storage sata_nv libata raid0 sd_mod scsi_mod ext3 jb
d uhci_hcd ohci_hcd ehci_hcd
Sep 23 17:55:31 tango055 kernel: Pid: 0, comm: swapper Not tainted
2.6.26.3 #2
Sep 23 17:55:31 tango055 kernel:
Sep 23 17:55:31 tango055 kernel: Call Trace:
Sep 23 17:55:31 tango055 kernel:  <IRQ>  [<ffffffff802308a5>]
warn_on_slowpath+0x51/0x79
Sep 23 17:55:31 tango055 kernel:
[<ffffffffa00b1f50>] :forcedeth:reg_delay+0x40/0x8a
Sep 23 17:55:31 tango055 kernel:
[<ffffffffa00b2b28>] :forcedeth:nv_drain_tx+0xb4/0x186
Sep 23 17:55:31 tango055 kernel:
[<ffffffffa00b7156>] :forcedeth:nv_tx_timeout+0x1f1/0x29b
Sep 23 17:55:31 tango055 kernel:  [<ffffffff803c273a>] dev_watchdog
+0x0/0xfb
Sep 23 17:55:31 tango055 kernel:  [<ffffffff803c273a>] dev_watchdog
+0x0/0xfb
Sep 23 17:55:31 tango055 kernel:  [<ffffffff803c27e0>] dev_watchdog
+0xa6/0xfb
Sep 23 17:55:31 tango055 kernel:
[<ffffffffa00b19c8>] :forcedeth:nv_do_stats_poll+0x0/0x3b
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8023856e>] run_timer_softirq
+0x12c/0x192
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8023501b>] __do_softirq
+0x55/0xc4
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8020cf1c>] call_softirq
+0x1c/0x28
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8020e5be>] do_softirq
+0x2c/0x68
Sep 23 17:55:31 tango055 kernel:  [<ffffffff802195da>]
smp_apic_timer_interrupt+0x8a/0xa4
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8020af78>] default_idle
+0x0/0x3c
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8020c9c6>]
apic_timer_interrupt+0x66/0x70
Sep 23 17:55:31 tango055 kernel:  <EOI>  [<ffffffff8020af9f>]
default_idle+0x27/0x3c
Sep 23 17:55:31 tango055 kernel:  [<ffffffff8020ab82>] cpu_idle
+0x6d/0x8b
Sep 23 17:55:31 tango055 kernel:
Sep 23 17:55:31 tango055 kernel: ---[ end trace 368cd674b4c787ca ]---


--=20
Brett Pemberton - VPAC Senior Systems Administrator
http://www.vpac.org/ - (03) 9925 4899

--=-jNhCqOmwp6y7e9Gdg5Y9
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjZirwACgkQ/XtBayFVLhOeJgCg0yPMMMw+RNOEHVyQ+Bli0Xmq
A3QAn2pkPCpz4QYvbGZN7aVEB8U2fiQD
=+TnF
-----END PGP SIGNATURE-----

--=-jNhCqOmwp6y7e9Gdg5Y9--
