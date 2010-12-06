From: Ben Hutchings <benh@debian.org>
Subject: Re: [PATCH] net/r8169: Remove the firmware of RTL8111D
Date: Mon, 06 Dec 2010 04:38:04 +0000
Message-ID: <1291610284.8025.154.camel@localhost>
References: <1291180966-3124-1-git-send-email-hayeswang@realtek.com>
	 <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-I8m2Ks49olXaYRg4WgLu"
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40232 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752042Ab0LFEiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 23:38:13 -0500
In-Reply-To: <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-I8m2Ks49olXaYRg4WgLu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-12-01 at 09:07 +0100, Francois Romieu wrote:
> Hayes Wang <hayeswang@realtek.com> :
> > Remove the firmware of RTL8111D from the kernel.
> > The binary file of firmware would be moved to linux-firmware repository=
.
>=20
> The driver can not simply go along when request_firmware fails. Though Be=
n's
> code did not take care of it, the driver should imho propagate some retur=
n
> code. Ben ?
[...]

Sorry I haven't been more responsive on this.

I have reports that the RTL8111D/8168D hardware can work without this
firmware, possibly with limited functionality or compatibility.  (I
assume it is a patch for the original firmware loaded from ROM or
flash.)  So I feel obliged to give users the choice to use the driver
without installing non-free firmware.  If you want to make the warning
on failure of request_firmware() more explicit then that's OK with me.
If you make the failure fatal I will probably revert that in Debian.

Ben.

--=20
Ben Hutchings, Debian Developer and kernel team member


--=-I8m2Ks49olXaYRg4WgLu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATPxop+e/yOyVhhEJAQLmBQ//WAWk130ey10SL7If+VEVV+ztqh8MRnkk
DPl9nQVjeoLYBNRDZcSzizy5gf5EcJ5OZIbqKUxuKZ+Rhvq0veSwilXkW3X8g2kp
gh3U3X/8DLL7xios8lZoDT9IcFJl4tDSy5u1mdphHSB+tjcGEYsSxc51SwXxZmut
p2xXxsVxM6j9Y1a/MixNG0YN71TAg/wN+PF7s//Mz3wIJIeG6/v1/OtuiUSz9GLm
19UMK+y54dkP+kbIJUb0y/jMJ+yU+3ED6Gn6SF8sk9UUa07Gv8KaVM3TmcSzCoG6
1zIxmaEyqIclis0pM12dxeMvuMlibHDRZqnNxaIKBdnmhDDBggXYOYXB5UrTeP0t
+/mBhBPhiP7w6ZC3KbpFb314CQqxMkaoDApJMEH5ZoOKkIR46pM4/I9XfKuRjO5A
X4FptUkW3D/VPPaZZo/k2RIBz/6m/uErfr4GuZ63K7UQ4dyv59avzBQU4BnzTHIS
7GWF6+bg/h1LMWIpLSYG5nVco4S5sIDtrgQGJPs9fVicn15f9B8/OjYl3ZtwojZ3
mw1Vzx764csMu7/AenCd61OFq9erbrjxkyJz8sXSP13qmFwsfaNTDU3cccaX9dNJ
tnvP/8nTO9Fnr65woX/TxrYiVwg/BDjRtzUg29USQx9niz1JM4dBG1Xsg19P3vwG
YyonLEcqYc4=
=deuX
-----END PGP SIGNATURE-----

--=-I8m2Ks49olXaYRg4WgLu--
