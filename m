From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Tue, 13 Mar 2007 19:31:50 +0000
Message-ID: <20070313193149.GA27175@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5502C.1000905@ru.mvista.com> <20070312191120.GA3085@sirena.org.uk> <45F6ACF2.2050300@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4739 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933345AbXCMTeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 15:34:20 -0400
Content-Disposition: inline
In-Reply-To: <45F6ACF2.2050300@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 13, 2007 at 04:53:54PM +0300, Sergei Shtylyov wrote:
> Mark Brown wrote:

> >confused and eventually locks up.  Before locking up it will usually
> >report one or more oversided packets so this is a useful hint that we
> >should reset the recieve state machine in order to recover from this.

>    That's all good by why we need to completely lose TX and other interru=
pts
> in the meantime? High inbound traffic doesn't necessarily mean a high=20
> outbound one, does it?

While the code in the driver can cope if the chip takes a while to
respond to the reset as far as I have been able to tell in testing=20
it does so close enough to immediately to avoid repeating the loop at
all.  The effect on transmit processing should be minimal.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRfb8Ig2erOLNe+68AQIbtQP/bD4q4RaUS+/4cwOuSKYz0B3NL9i4j/p9
pk2szKSITNcy/hSk6iDkenzZEfCTlh3iNkrNYZhmEHv8hqUrphzXiQkSOX4+52dJ
XArwx+G1ETq0o71VdFnlmFiqQ6EQHgU10DHv0MvbgPtV0yT6zWFzWXfHWLfrRH2U
/j3Ta37O/zo=
=xh31
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
