From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 13:48:00 -0700
Message-ID: <20060524204800.GH22881@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org> <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org> <20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZOudaV4lSIjFTlHv"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:22069 "EHLO
	alt") by vger.kernel.org with ESMTP id S932383AbWEXUsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 16:48:03 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1148501433.5325.52.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZOudaV4lSIjFTlHv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 24, 2006 at 04:10:32PM -0400, jamal wrote:
> Can you provide some link to a vendor that allows resetting ethernet
> stats? I am almost certain, if they do they will have something or other
> which indicates that such a reset happened. It is also easier for cisco
> to have none standard feature "as of ios 15.16" which could support such
> behavior because they bundle everything including network management
> tools. We dont have that luxury. The BSDs may actually get away with it
> because they bundle user space apps as well. Perhaps some
> random Linux vendor as well..

Well, I can show you support on my home switch (cabletron) - the network gu=
ys
will be a little unhappy if I clear stats on our production network (cisco)
without warning them:

***************************************************************************=
**
Cabletron Systems ELS100-24TXG

SWITCH STATISTICS                                 Access Control: READ/WRITE

 ID    TRANSMITTED    RECEIVED   FORWARDED    FILTERED     DROPPED     ERRO=
RED
---------------------------------------------------------------------------=
--
  1        1322815     1614038     1614038           0           0       51=
562
  2        2067032    18142545    18142349           0         196         =
  0
  3       17487573     1011964     1011964           0           0         =
  0
  4          18247       20528       20528           0           0         =
  0
  5          38775           0           0           0           0         =
  0
  6          38775           0           0           0           0         =
  0
  7          38775           0           0           0           0         =
  0
  8          38775           0           0           0           0         =
  0
  9          38820           0           0           0           0         =
  0
 10          38820           0           0           0           0         =
  0

  n. Next Page    p. Previous Page    f. First Page    l. Last Page

  s. Switch Summary       d. Port Statistics     t. Trunking Statistics
  r. Refresh   c. Clear   x. Previous Menu

Enter Selection:c

***************************************************************************=
**
Cabletron Systems ELS100-24TXG

SWITCH STATISTICS                                 Access Control: READ/WRITE

 ID    TRANSMITTED    RECEIVED   FORWARDED    FILTERED     DROPPED     ERRO=
RED
---------------------------------------------------------------------------=
--
  1              0           0           0           0           0         =
  0
  2              0           0           0           0           0         =
  0
  3              0           0           0           0           0         =
  0
  4              0           0           0           0           0         =
  0
  5              0           0           0           0           0         =
  0
  6              0           0           0           0           0         =
  0
  7              0           0           0           0           0         =
  0
  8              0           0           0           0           0         =
  0
  9              0           0           0           0           0         =
  0
 10              0           0           0           0           0         =
  0

  n. Next Page    p. Previous Page    f. First Page    l. Last Page

  s. Switch Summary       d. Port Statistics     t. Trunking Statistics
  r. Refresh   c. Clear   x. Previous Menu

Enter Selection:

> > If my patch was invasive and broke things,=20
>=20
> It _does break_ things for all known management apps.=20
> This is not to say it is not useful for testing, development or
> debugging (which is what you seem to be using it for) but it does mean
> it is broken.=20

Does having the ability to boot into single user mode break networking? No,=
 it
*allows* you to break networking. Does the _support_ of rmmod break the
kernel? No, but it *allows* you to.

Same thing here. The patch breaks nothing, it provides a tool that if used
without proper understanding, could break things. Just like almost any other
feature in the kernel.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--ZOudaV4lSIjFTlHv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEdMaAN5XoxaHnMrsRAuruAJwJpy26dwc6y580DxIvXmIgSEIbxgCcDHjr
9bnx++IT1ajJfCsQtlMn+1I=
=jGt2
-----END PGP SIGNATURE-----

--ZOudaV4lSIjFTlHv--
