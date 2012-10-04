From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 4 Oct 2012 11:06:15 +1000
Message-ID: <20121004110615.3fda3c25735284c776106d7d@canb.auug.org.au>
References: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au>
	<20121003.205053.1711360628623711137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__4_Oct_2012_11_06_15_+1000_zC9cWyQEG8ngUGt6"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vipul@chelsio.com, jay@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121003.205053.1711360628623711137.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__4_Oct_2012_11_06_15_+1000_zC9cWyQEG8ngUGt6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

On Wed, 03 Oct 2012 20:50:53 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I do have a question though, it is honestly really that much easier to
> revert a whole days worth of changes (and therefore not get the code
> tested at all) than to simply add the obvious one liner?

Actually, for me it is.  I have a script that does the "use yesterday's
version" for me.  To fix (even a one liner) means bringing up an editor,
commiting, creating the patch and then recommiting it (an implementation
detail) and recording that I need to keep (automatically) applying the
patch in case the maintainer doesn't react quickly.

In this particular case I have been telling people to include vmalloc.h
(and other things like slab.h) over and over for years ... its a pain
that x86 builds indirectly include so much stuff.

> It seems to me to be absolutely the wrong tradeoff in these situations.

I guess for the "current/fixes" tree during the merge window, you are
right.  For the "normal" trees, does a delay of (usually) one day really
matter?

I used to fix all this stuff and it added considerably to the length of
my work day (which currently can be up to 16 hours long) :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__4_Oct_2012_11_06_15_+1000_zC9cWyQEG8ngUGt6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQbOEHAAoJEECxmPOUX5FEZcIP/irt21hj7yjKiafCt4qzo7Ye
jqdEGP2ogJkd/2ZTe+FG/EPZQC3Fn1+ujrcJlWLSioz05D58bOLTxBswcIrIqriB
WYMPxAM1MZ/XQf6Jk85tGLesXdrH2JIVxXKWizaCe5GU0KgvGpNIGd7jxG3N5UOf
RTzvoCHrr8sGYdGKusVPxY2NoqTCljrKlJWfzC6aspKpzzcE5juibDrinvLqJUFl
Er18trcRHMYZvc/laBR9uZddZOwQBteE/1fxlk763Xw2oj1d984E5yYjvDtyU7e5
m3kK2RzTsYNfqQK1wjNWXfE3lOeKTkncCpQfbUuTPFtwlSPAUatRu8MXqZ5zKC6l
gp1sxWEk5Ryra/KdSXgmrYly5mf2mw9g1clgCLXiup67FgNQOD9VCJcvgw1X45zH
H29nOrsfKYdU97Ux4QxpHjfgelhivS0uWaFzgo+faY4PrzajHb0xDWgo7ClTudpC
2MPi318LarMl4YGw0W7voUesLbSE+nhoIyTMGdU/8xW4CRFXLiyxKF4nwC0xNZq6
40CvX2Zs03d3vK2fIzYZkIc+E1WbWdcx0dslI11XxMbahQjdpKGe26ca9m293mho
/6yKkecEOrk9hyGvaKm11uhkWYOXguzZEA/K41zATSjteEnZ0OEmbibkNnlfw6B+
tC91AKuXksNKRFzhmdoO
=2BSs
-----END PGP SIGNATURE-----

--Signature=_Thu__4_Oct_2012_11_06_15_+1000_zC9cWyQEG8ngUGt6--
