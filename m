From: "Udo A. Steinberg" <us15@os.inf.tu-dresden.de>
Subject: Linux-2.5.73 + e100
Date: Tue, 24 Jun 2003 16:29:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624162919.09a45dc0.us15@os.inf.tu-dresden.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="=.7MjGUDTPHVX9dg"
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>,
   Linux Network Mailing List <linux-net@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=.7MjGUDTPHVX9dg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


Hi,

Just tried out the e100 driver which comes with 2.5.73, i.e. not the new one
from sourceforge, with the following result. The machine is a dual Xeon box.

Regards,
-Udo.

Intel(R) PRO/100 Network Driver - version 2.3.13-k1
Copyright (c) 2003 Intel Corporation

e100: selftest OK.
irq 9: nobody cared!
Call Trace:
 [<c010b314>] __report_bad_irq+0x2a/0x8b
 [<c010b3fe>] note_interrupt+0x6f/0x9f
 [<c010b715>] do_IRQ+0x161/0x192
 [<c0109aa4>] common_interrupt+0x18/0x20
 [<c0258eb3>] e100_mdi_read+0x50/0xdb
 [<c0259759>] e100_auto_neg+0xeb/0x112
 [<c0258e38>] e100_mdi_write+0xb0/0xdb
 [<c02597b8>] e100_phy_set_speed_duplex+0x38/0xa7
 [<c03e7dd3>] e100_phy_init+0x71/0x80
 [<c0253f0f>] e100_hw_init+0x13/0x10b
 [<c03e73c8>] e100_rd_pwa_no+0x31/0x3f
 [<c03e7127>] e100_init+0xee/0x118
 [<c03e6a47>] e100_found1+0x226/0x3f9
 [<c02038c0>] pci_device_probe_static+0x52/0x63
 [<c0203a46>] __pci_device_probe+0x3b/0x4d
 [<c0203a87>] pci_device_probe+0x2f/0x4d
 [<c024251c>] bus_match+0x45/0x73
 [<c0242615>] driver_attach+0x59/0x5d
 [<c0242896>] bus_add_driver+0x94/0xa7
 [<c0203d59>] pci_register_driver+0x80/0xa8
 [<c03e6c31>] e100_init_module+0x17/0x57
 [<c03d085c>] do_initcalls+0x27/0x92
 [<c012f268>] init_workqueues+0xf/0x26
 [<c01050c9>] init+0x5b/0x1f6
 [<c010506e>] init+0x0/0x1f6
 [<c0107029>] kernel_thread_helper+0x5/0xb

handlers:
[<c0205f63>] (acpi_irq+0x0/0x16)
Disabling IRQ #9
e100: eth0: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled

--=.7MjGUDTPHVX9dg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.3.1 (GNU/Linux)

iD8DBQE++GBCnhRzXSM7nSkRAjCKAJ9jdbHFMh3Y0qjYoNl+kzyqzpj0sACeI2vt
d/zcQaJZmYB26h0Fk4eXDBY=
=3Pup
-----END PGP SIGNATURE-----

--=.7MjGUDTPHVX9dg--
