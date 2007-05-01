From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 1 May 2007 09:46:40 +0100
Message-ID: <20070501084639.GA528@sirena.org.uk>
References: <46365887.3010705@interia.pl> <20070430205522.abad2481.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Cc: =?utf-8?B?UmFmYcWC?= Bilski <rafalbilski@interia.pl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:1425 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031618AbXEAJSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 05:18:24 -0400
Content-Disposition: inline
In-Reply-To: <20070430205522.abad2481.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 30, 2007 at 08:55:22PM -0700, Andrew Morton wrote:
> On Mon, 30 Apr 2007 22:58:47 +0200 Rafa=C5=82 Bilski <rafalbilski@interia=
=2Epl> wrote:
> > > ezri user.info kernel: eth0: DSPCFG accepted after 0 usec.
> > > ezri user.notice kernel: eth0: Wake-up event 0x80000a
> > > ezri user.info kernel: eth0: Setting full-duplex based on negotiated =
link capability.

Could you please run "ethtool -s eth0 msglvl 0xffffffff" to turn logging
=66rom the driver right up and send a log?  This will spam the log if
there is any traffic but should say why the driver is doing this.

> It seems to be repeatedly setting the same duplex setting.  The closest
> thing I can see in there in recent times is
> 68c90166e4aaa15ddcdd4778ad30bfb8b32534be, "Add support for using MII port
> with no PHY".

It's not just setting the same duplex setting, the WoL message indicates
that it's doing that as part of init_registers() which should only be
happening in error handling paths and during resume or open.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRjb+aw2erOLNe+68AQJS+gP/UzGR+zjHi9X/Hk73MteDEqctNx2f383+
QnwzQ/OSRo7/fCmtlE8HYPHbQAMQCzi43PO+HCNVzvBBZoXrHC0nnbTy7ctK6T5H
/KFFp4wlAqzI320AdwC6cZrzwnEEZHmDytgj6jbz+F97FoKsVfZCSFanMQgerNKZ
loFn9ZzI5TQ=
=DaaL
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--
