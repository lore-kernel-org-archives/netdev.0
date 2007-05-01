From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 1 May 2007 19:08:31 +0100
Message-ID: <20070501180830.GA31630@sirena.org.uk>
References: <46365887.3010705@interia.pl> <20070430205522.abad2481.akpm@linux-foundation.org> <20070501084639.GA528@sirena.org.uk> <46371590.4090004@interia.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4021 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258AbXEASI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 14:08:57 -0400
Content-Disposition: inline
In-Reply-To: <46371590.4090004@interia.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 01, 2007 at 12:25:20PM +0200, Rafa=C5=82 Bilski wrote:

> eth0: Media selection timer tick.
> eth0: possible phy reset: re-initializing

This is why the reset is being triggered - it's a workaround for a hardware
bug which checks to make sure the hardware is in the state that the
kernel thinks it is is going off.  The code has this explanatory comment:

 * 2) check for sudden death of the NIC:
 *    It seems that a reference set for this chip went out with incorrect i=
nfo,
 *    and there exist boards that aren't quite right.  An unexpected voltage
 *    drop can cause the PHY to get itself in a weird state (basically rese=
t).
 *    NOTE: this only seems to affect revC chips.

I'd suggest checking your power supply as a first step.

[BTW, as Andrew said please don't drop people from the CC.]

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRjeCGw2erOLNe+68AQLrcAP/Xc9DKNgyVpeFcH1Llb7KSzqcY+2pWftK
LVcJrHiVt9cmJaR3v+CxQ+ISvmUHv8ampBPULEKjixT/w5TRonkpBP2I7ye81ei8
U7C2Wslx58oVtjI43nkTnAFyjq6iLCdt7OyY9jIx2JGDVwdzzDa70J2JpsceQ3BW
XmRZmVnrX5Y=
=qyTT
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
