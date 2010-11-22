From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: ixgbe dump
Date: Mon, 22 Nov 2010 15:22:13 -0800
Message-ID: <1290468133.2603.2.camel@jtkirshe-MOBL1>
References: <4CE47FA6.8050600@kernel.org>
	 <29F4ED941D916B48B88B4D2A4F3D1B9C01CBFC68C5@orsmsx509.amr.corp.intel.com>
	 <AANLkTinQ-6CaUY3bYd+SMBCaNvU5YiXL2P+gh7N1tM-x@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-1zVR6Ho0i4/Uj2p8szXG"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4903 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757881Ab0KVXWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 18:22:17 -0500
In-Reply-To: <AANLkTinQ-6CaUY3bYd+SMBCaNvU5YiXL2P+gh7N1tM-x@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1zVR6Ho0i4/Uj2p8szXG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-11-22 at 14:41 -0800, Yinghai Lu wrote:
> On Thu, Nov 18, 2010 at 11:30 AM, Skidmore, Donald C
> <donald.c.skidmore@intel.com> wrote:
> >>-----Original Message-----
> >>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org=
] On
> >>Behalf Of Yinghai Lu
> >>Sent: Wednesday, November 17, 2010 5:22 PM
> >>To: Brandeburg, Jesse; David Miller
> >>Cc: NetDev
> >>Subject: ixgbe dump
> >>
> >>[ 1546.287521] md: stopping all md devices.
> >>[ 1547.283729] kvm: exiting hardware virtualization
> >>[ 1547.292876] sd 2:2:1:0: [sdb] Synchronizing SCSI cache
> >>[ 1547.293831] sd 2:2:0:0: [sda] Synchronizing SCSI cache
> >>[ 1547.299627] BUG: unable to handle kernel NULL pointer dereference at
> >>0000000000000033
> >>[ 1547.315819] IP: [<ffffffff81746273>] ixgbe_set_rx_mode+0x265/0x38e
> >>[ 1547.316448] PGD 3ff4487067 PUD 3ff216b067 PMD 0
> >>[ 1547.335626] Oops: 0000 [#1] SMP
> >>[ 1547.335941] last sysfs file: /sys/kernel/kexec_loaded
> >>[ 1547.336381] CPU 0
> >>[ 1547.336548] Modules linked in:
> >>[ 1547.355798]
> >>[ 1547.355968] Pid: 25630, comm: kexec Not tainted 2.6.37-rc2-tip-yh-01=
961-
> >>g6034289-dirty #281      /Sun Fire X4800
> >>[ 1547.375849] RIP: 0010:[<ffffffff81746273>]  [<ffffffff81746273>]
> >>ixgbe_set_rx_mode+0x265/0x38e
> >>[ 1547.395543] RSP: 0018:ffff881fb9d49ce8  EFLAGS: 00010287
> >>[ 1547.396080] RAX: 0000000000000000 RBX: ffff88dffe5a0940 RCX:
> >>ffff88dffe5a0940
> >>[ 1547.415635] RDX: 0000000000000000 RSI: 0000000000000001 RDI:
> >>ffffc90077780000
> >>[ 1547.416299] RBP: ffff881fb9d49d48 R08: 0000000000000000 R09:
> >>0000000000000000
> >>[ 1547.435860] R10: 000000000000a608 R11: 0000000000000000 R12:
> >>0000000000000000
> >>[ 1547.455516] R13: ffff88dffe5a0000 R14: 0000000000003400 R15:
> >>ffff881fb9d49db7
> >>[ 1547.456257] FS:  00000000006e0850(0063) GS:ffff88207d600000(0000)
> >>knlGS:0000000000000000
> >>[ 1547.475937] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>[ 1547.495330] CR2: 0000000000000033 CR3: 0000003ffa77e000 CR4:
> >>00000000000006f0
> >>[ 1547.496009] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> >>0000000000000000
> >>[ 1547.515594] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> >>0000000000000400
> >>[ 1547.516229] Process kexec (pid: 25630, threadinfo ffff881fb9d48000, =
task
> >>ffff881f8a57a2d0)
> >>[ 1547.536039] Stack:
> >>[ 1547.536244]  0000000000000040 0000002b00000000 ffff881ffedc1000
> >>0000000000000006
> >>[ 1547.555894]  ffff88dffe5a1b40 0b00000081454ec8 ffff881fb9d49d48
> >>ffff88dffe5a0940
> >>[ 1547.575411]  ffff881ffedc1000 000000000000001e 0000000000000000
> >>ffff881fb9d49db7
> >>[ 1547.576131] Call Trace:
> >>[ 1547.595251]  [<ffffffff8174a8f4>] __ixgbe_shutdown+0x9d/0x153
> >>[ 1547.595770]  [<ffffffff8174a9c4>] ixgbe_shutdown+0x1a/0x43
> >>[ 1547.615250]  [<ffffffff814574bb>] pci_device_shutdown+0x2c/0x40
> >>[ 1547.615887]  [<ffffffff8151c5e9>] device_shutdown+0x75/0xb0
> >>[ 1547.635268]  [<ffffffff8108f461>] kernel_restart_prepare+0x2c/0x33
> >>[ 1547.635927]  [<ffffffff810bc821>] kernel_kexec+0x38/0x6b
> >>[ 1547.655252]  [<ffffffff8108f618>] sys_reboot+0x156/0x194
> >>[ 1547.655765]  [<ffffffff8114422a>] ? __d_free+0x59/0x5e
> >>[ 1547.675145]  [<ffffffff81144283>] ? d_free+0x54/0x66
> >>[ 1547.675612]  [<ffffffff8114439d>] ? d_kill+0x3b/0x43
> >>[ 1547.695025]  [<ffffffff81144a1c>] ? dput+0x40/0x140
> >>[ 1547.695539]  [<ffffffff811351a9>] ? fput+0x1d7/0x1e6
> >>[ 1547.696045]  [<ffffffff81036c0c>] ? sysret_check+0x27/0x62
> >>[ 1547.715426]  [<ffffffff81cd9772>] ? trace_hardirqs_on_thunk+0x3a/0x3=
f
> >>[ 1547.734897]  [<ffffffff81036bdb>] system_call_fastpath+0x16/0x1b
> >>[ 1547.735428] Code: d2 e9 81 00 00 00 48 8b 83 00 12 00 00 8b 80 88 50=
 00
> >>00 0d 00 00 00 80 e9 a7 00 00 00 48 8b 81 00 0a 00 00 48 8b bb 00 12 00=
 00
> >><0f> b6 40 33 83 f8 3f 7f 0d 89 c6 c1 e6 06 81 c6 28 10 00 00 eb
> >>[ 1547.775262] RIP  [<ffffffff81746273>] ixgbe_set_rx_mode+0x265/0x38e
> >>[ 1547.775909]  RSP <ffff881fb9d49ce8>
> >>[ 1547.794997] CR2: 0000000000000033
> >>[ 1547.795987] ---[ end trace 4ed9616adc45007c ]---
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > Thanks for the dump.
> >
> > I believe I've found the problem and will get a patch to Jeff shortly.
>=20
> Did you have that patch posted already?
>=20
> Thanks
>=20
> Yinghai

It is not posted yet. Don got the patch to our testers and they are
doing a quick validation on the patch before I post it to netdev.

I can send you the patch, so that you can assist in letting us know if
it resolves the issue.

Cheers,
Jeff

--=-1zVR6Ho0i4/Uj2p8szXG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM6vsbAAoJECTsCADr/EWU4a4H/0giSSKE/L1yzVDMkEEBl+Tc
ywbFF0GoPKljSUWqnQnFYqDJE8HwJJmWu9TOyrulwFEBmS8fSANFgoYT+WWNaTYT
0bWTOaxClnDw1m/VjGitmOyIIx4Sa4/1yzPGgN9wg/PJDT1siRORVEn7pHFj88QJ
KzvgCuJhYxcMtLMwKQ25Uzdsc/5QOUsov6IqOxViFMKXl/28Hho+DG+ocWE7U0mz
XsG9cXjbeYTWCeoBdWyv9BzgM67/EOA7bYSQbXVNmBWI+oQotyYx+qDk3Hp730F1
5xRhSbM0by6GH1Mo5lkeu+2MbtUyzI4Bfw2jg54y1tfZPPNjHRzebWuqbdEtNBQ=
=v281
-----END PGP SIGNATURE-----

--=-1zVR6Ho0i4/Uj2p8szXG--

