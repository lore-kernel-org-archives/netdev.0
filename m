From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH iputils 5/6] tftpd: fix syslog setup
Date: Thu, 2 Jun 2016 00:33:08 -0400
Message-ID: <20160602043308.GM7717@vapier.lan>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <1464752905-10347-5-git-send-email-vapier@gentoo.org>
 <574F958D.4060409@miraclelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="NgG1H2o5aFKkgPy/"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:56200 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbcFBEdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 00:33:09 -0400
Content-Disposition: inline
In-Reply-To: <574F958D.4060409@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NgG1H2o5aFKkgPy/
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 02 Jun 2016 11:10, YOSHIFUJI Hideaki wrote:
> Mike Frysinger wrote:
> > Commit d81a44625b04d487c895473aa77af13420b7afdd added support for check=
ing
> > the set*id calls, but would call syslog() before it had called openlog(=
).
> > Move the call up earlier to fix that.
>=20
> Please describe what it really fixes.

i already did: you need to call openlog before calling syslog, but the
code here very clearly doesn't.  if you read the commit i referenced,
and the all <25 lines of context here, it should be pretty obvious the
code is wrong.
-mike

--NgG1H2o5aFKkgPy/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXT7cEAAoJEEFjO5/oN/WBR8wP/2yz4UvTcrOkTvcHLJQIc7J8
g/tnDlBe6RU+hizeDKKyaJQPYYVnB19xeTg+ryCtWMo4HPqhMyvoj+cCUKmSKUSy
pTStwnvzHqshIV2JsMynxp2kB96AdspduI0C1uCGfrarC4OUEcu6Q4A30HjG7VX6
HBhIKVTHQuNInmPCPW8GCr5uuXbIvMAEJAoOwVO8AJGUj7SYELC2QUVEPKPxUgSF
dK405Kswwg2My5TkepaXxcxnTeL5hin3w9PARynjIszsvGmu3/6LEwB3wc7DNHr7
jvqlfDOOPHd+iXZmSaTFBGM/iXigrb2q4SkGBUzfwy6Zr/jmxIh6thHKBcRdl+t3
6inJl2jdLDnMeYTKFm1QzqTLXtJ4y6HEhkx96gULKJKNE+2WvTgaoBJI66gbZout
JfTJMStybHK973Qw0zLFlcPXpHLSaNFAvjyrYRfkkjQsStgGo6Jzy2dwrIAIP48x
bVDJe+N0Sj6qK7pooleC/hUXOsHGzvsZGquI3+R9GutawPjHHZWNdnrSLJQWV9Zg
UMR8O7s9ixIRU07k27lqGLzQdxflWGk9axPYyMxGK7LFj1VZWhxTK1tAWqsaKlZF
VDXwMWhqHEZg2lZcefVlhsE5rwmHhGIVmMBNorsgQccMD0+/5ePdDmnP4A/BX6b/
NeBvXDbEYeOP8bWwNs9k
=G6IR
-----END PGP SIGNATURE-----

--NgG1H2o5aFKkgPy/--
