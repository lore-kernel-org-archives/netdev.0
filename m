From: Erik Mouw <mouw@nl.linux.org>
Subject: Re: [PATCH] xircom_cb should return NETDEV_TX_BUSY when there are
	no descriptors available
Date: Mon, 4 Feb 2008 22:20:37 +0100
Message-ID: <20080204212037.GB11417@gateway.home>
References: <20080204175653.GC16952@gateway.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="St7VIuEGZ6dlpu13"
Cc: netdev@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	jamal <hadi@cyberus.ca>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr15.xs4all.nl ([194.109.24.35]:2049 "EHLO
	smtp-vbr15.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbYBDVV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 16:21:57 -0500
Content-Disposition: inline
In-Reply-To: <20080204175653.GC16952@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 04, 2008 at 06:56:54PM +0100, Erik Mouw wrote:
> Changes in other networking paths uncovered a bug in the xircom_cb
> driver which made the kernel spew lots of the following error messages:
>=20
>   BUG eth1 code -5 qlen 0
>=20
> It turned out that the driver returned -EIO when there was no
> descriptor available for sending packets. It should return
> NETDEV_TX_BUSY instead. This was discussed on the netdev list before,
> see http://thread.gmane.org/gmane.linux.network/84603 .
>=20
> Signed-off-by: Erik Mouw <mouw@nl.linux.org>

Forgot to tell: the patch is against 2.6.24 but should apply cleanly to
the latest git kernel. The xircom_cb driver appears to be orphaned so
I've send the patch to you.


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--St7VIuEGZ6dlpu13
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHp4Gl/PlVHJtIto0RAngFAJ9ZXFe1Q5diA4tkHsSOD3Y4+Es3mgCfRXay
3UmgcIhXIHSH9LgWJB53LB4=
=l4uS
-----END PGP SIGNATURE-----

--St7VIuEGZ6dlpu13--
