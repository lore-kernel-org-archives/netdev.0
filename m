From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 1 May 2007 22:27:51 +0100
Message-ID: <20070501212750.GC31630@sirena.org.uk>
References: <46365887.3010705@interia.pl> <20070430205522.abad2481.akpm@linux-foundation.org> <20070501084639.GA528@sirena.org.uk> <46371590.4090004@interia.pl> <20070501180830.GA31630@sirena.org.uk> <46379A7E.3000109@interia.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lCAWRPmW1mITcIfM"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4114 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423672AbXEAV2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 17:28:38 -0400
Content-Disposition: inline
In-Reply-To: <46379A7E.3000109@interia.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lCAWRPmW1mITcIfM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 01, 2007 at 09:52:30PM +0200, Rafa=C5=82 Bilski wrote:

> >  * 2) check for sudden death of the NIC:
> >  *    It seems that a reference set for this chip went out with incorre=
ct info,
> >  *    and there exist boards that aren't quite right.  An unexpected vo=
ltage
> >  *    drop can cause the PHY to get itself in a weird state (basically =
reset).
> >  *    NOTE: this only seems to affect revC chips.

> Code commented out and NIC is working OK. Strange.
> eth0: DSPCFG accepted after 0 usec.
> eth0: link up.
> eth0: Setting full-duplex based on negotiated link capability.
> dspcfg =3D 0x00000000  np->dspcfg =3D 0x00005060

Oh, that's entertaining.  I have to confess that I've never seen an that
triggered the workaround before - adding the maintainer, Tim Hockin, who
may be able to shed some light on the expected behaviour here?

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--lCAWRPmW1mITcIfM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRjew0g2erOLNe+68AQLB7gP/UF8EfsfYk3DpjOXTDxpq3sQULwcfwbKx
AqbjNFlQU+W/LuIBYIuUN5yYGRGHzGYE8u8lrjz25xXPDlia/K7YPbR6kJa68cTM
JUmeX6HD3h1PoYt5jUwzq4ZiIQP9mZJObGA5VLQ10erd+aKEE5Mz25wxVq0xX9ix
ZUn0gafqhM4=
=bjmt
-----END PGP SIGNATURE-----

--lCAWRPmW1mITcIfM--
