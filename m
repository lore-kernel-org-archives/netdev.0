From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [HELP] BAD interrupts
Date: Thu, 24 Dec 2009 09:43:50 +1100
Message-ID: <1261608230.3401.16.camel@concordia>
References: <9F4C7D19E8361D4C94921B95BE08B81BA09038@zin33exm22.fsl.freescale.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-a8z+M6HPVNTWjxaBHwuz"
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54566 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbZLWWnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 17:43:52 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA09038@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a8z+M6HPVNTWjxaBHwuz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-12-23 at 19:41 +0530, Kumar Gopalpet-B05799 wrote:
> Hi all,
> =20
> I am trying linux 2.6.32-rc3 in SMP mode. I am seeing a lot of BAD
> interrupts when I do a "cat  /proc/interrupts".
> =20
> I am running a forwarding application b/w two ethernet ports (ethernet
> uses gianfar driver).
> =20
> Has any one observed these BAD interrupts ? If so, can someone help me
> in understanding why these interrupts come and how to resolve it ?

You'll need to tell us what platform you're running on.

The BAD interrupts come from ppc_spurious_interrupts. It's a count of
the number of times we entered do_IRQ() (ie. took an external
interrupt), but when we asked the interrupt controller which irq it was,
the interrupt controller said there was no irq.

Depending on your interrupt controller that might happen sometimes for
valid reasons. Or it might indicate something is setup wrong.

cheers


--=-a8z+M6HPVNTWjxaBHwuz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAksynSYACgkQdSjSd0sB4dKiuwCePaMae1nbzLfxaNDVRTNnFSk7
I0EAnAtrFG4So4e/E6t3ZosvkOStvtoB
=d8b5
-----END PGP SIGNATURE-----

--=-a8z+M6HPVNTWjxaBHwuz--

