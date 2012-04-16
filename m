From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Mon, 16 Apr 2012 15:29:10 +0100
Message-ID: <1334586550.3209.128.camel@deadeye>
References: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>
	 <1334498215.3209.4.camel@deadeye> <4F8C0EE1.7030901@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yKeIbf+Eb9Q2Xqt9+Nu3"
Cc: linux-kernel@vger.kernel.org, Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47283 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753565Ab2DPO3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 10:29:20 -0400
In-Reply-To: <4F8C0EE1.7030901@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yKeIbf+Eb9Q2Xqt9+Nu3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-04-16 at 06:21 -0600, Tim Gardner wrote:
> On 04/15/2012 07:56 AM, Ben Hutchings wrote:
> > On Thu, 2012-04-12 at 14:34 -0600, Tim Gardner wrote:
> >> Cc: Jon Mason <jdmason@kudzu.us> Cc: netdev@vger.kernel.org=20
> >> Signed-off-by: Tim Gardner <tim.gardner@canonical.com> ---=20
> >> drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 ++ 1 file
> >> changed, 2 insertions(+)
> >>=20
> >> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> >> b/drivers/net/ethernet/neterion/vxge/vxge-main.c index
> >> 51387c3..dcef72d 100644 ---
> >> a/drivers/net/ethernet/neterion/vxge/vxge-main.c +++
> >> b/drivers/net/ethernet/neterion/vxge/vxge-main.c @@ -4856,3
> >> +4856,5 @@ vxge_closer(void) } module_init(vxge_starter);=20
> >> module_exit(vxge_closer); +MODULE_FIRMWARE("vxge/X3fw-pxe.ncf");=20
> >> +MODULE_FIRMWARE("vxge/X3fw.ncf");
> >=20
> > I don't agree; these firmware files are updates for the flash and
> > only need to be loaded once.
> >=20
> > Also: this driver's behaviour of automatically updating flash
> > without any confirmation seems quite dangerous.  The driver also
> > isn't usable after it performs such an update:
> >=20
> > printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must
> > be " "hard reset before using, thus requiring a system reboot or a
> > " "hotplug event.\n");
> >=20
> > So what is the point of integrating firmware update into the driver
> > at all?
> >=20
> > Ben.
> >=20
>=20
> I guess I'm confused about use of the MODULE_FIRMWARE() macro. I
> thought it merely described the names of the firmware files that were
> actually used by the driver and had no run-time impact. Regardless of
> whether firmware files are used on every load, why _not_ describe them
> to modinfo ?
[...]

Ah, that's a good question.  Quoting my own interpretation from
<1257629601.15927.361.camel@localhost>:

> Drivers that must load 'firmware' into the devices they drive should=20
> declare the names of the files they will request, using the
> MODULE_FIRMWARE() macro.  This enables other tools to discover these
> dependencies statically, and warn the user if firmware files are
> missing.

In Debian we use this to decide which files need to be copied into an
initramfs.  You use that too unless you've changed this feature of
initramfs-tools.  We warn when building an initramfs and during a major
kernel upgrade if it looks like a driver will be used and the
corresponding firmware isn't installed.

I also have an (unfinished) patch that will use this information for
CONFIG_FIRMWARE_IN_KERNEL.

In this case the firmware files are used to upgrade old flash, but since
the vendor has closed down there aren't going to be any further updates.
So the likelihood of the files actually being needed by the driver is
very small.

Ben.

--=20
Ben Hutchings
This sentence contradicts itself - no actually it doesn't.

--=-yKeIbf+Eb9Q2Xqt9+Nu3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT4wstue/yOyVhhEJAQo/JQ//WyytXe5sYTlLWMDNjeoCQ4NYWhJs8xJ8
arCMWjULGqXo1XfRLuVp0jG1lNpNUq7tnfVK3Kfgw9wO5QRo609fyjkMCbKz3Y8D
g+vkSH1OjV4aWkAZAsUndrRjC9p3OS95fCv/ASLA37bXZaRhS5q+Mq2LrdJF+8Tb
2lO80SUGeYR2KxVwg5AH2//2c3m6TM/0RTgtm2jbtykGvQ4jKPobuef++nOt7hlR
pXiKYA5qnMztYluPjP9YQ7OrD1hsVOXTKX8e2q3PExMRwadqrGpcIDMlm2Rc+x8x
EGMx00Jn6o47dASbPqIjhq+FMguE43FFygq4GMlv8z/h1V0tjZ05En5pyN3GchkV
Q+BdI909/MYSisnB+Fa3FJigNB3Jho26YLgDbD6n4yceFyJetFkmDC/fF0xYBNWt
C3daYb8pZxEIfLPNej+O0iQgJoo9kvABlK1tBNL8SHy8ZS6JrUp5uDXrYca6fOCM
1xQ2BgC2AhxW9h/Wp1fbqzbBLUaoZDphQBB6V6SVDdWrJr34qDXDYlXpKcGsVQmT
7ePF+jpIMWR8oAyAQmZxHhlp5J49wCOzdN/QE+r7Pg8s6A2tx+KidWdagD91/SV/
k1coKpHRCeoMf1Bx7wbr6HKy5PwVW2thXsU4nfKN0W9mFWXoK2Z2WpvMXaXw6RB7
e/woNeRG6GU=
=doyJ
-----END PGP SIGNATURE-----

--=-yKeIbf+Eb9Q2Xqt9+Nu3--
