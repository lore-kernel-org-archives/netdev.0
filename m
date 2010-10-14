From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 14 Oct 2010 15:07:33 -0700
Message-ID: <1287094053.5247.1.camel@jtkirshe-MOBL1>
References: <20101015113854.ae080284.sfr@canb.auug.org.au>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-cjIwwdzThmyfIp30ji47"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101015113854.ae080284.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cjIwwdzThmyfIp30ji47
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-10-14 at 17:38 -0700, Stephen Rothwell wrote:
> Hi all,
>=20
> After merging the net tree, today's linux-next build (x86_64 allmodconfig=
)
> failed like this:
>=20
> drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_configure_dcb':
> drivers/net/ixgbe/ixgbe_main.c:3377: error: implicit declaration of funct=
ion 'ixgbe_dcb_check_config'
>=20
> Caused by commit f32f837b75233588cd4f8542214a30915ab7847b ("ixgbe: remove
> unused functions").
>=20
> Grep is your friend :-)
>=20
> I have used the net tree from next-20101014 for today.

I apologize, this is my fault.  I have a patch coming to resolved the
issue.

--=-cjIwwdzThmyfIp30ji47
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAABAgAGBQJMt38dAAoJECTsCADr/EWUaAAH/A+X2zA4OdKtgb3Y4Ocyyl4/
yQyDcebF2hQOtgCRIuZ9Qyxne6tDqjwjO6Us7RBO4EO4DB7ctgYWHivWAVCQI4DY
0VN9XpobwI0pD9vo0tRZgNzck2cqZdqYeQg7AjPq2ZFizHE9bDCOZA/JsHk5Iakk
btK2po6YbetKWvP86JdiBa8K0OPhCA+0OWAN7k/ApXkYhzZNMb1RZyk3n0SYrexi
uh7mSdCj8RMyrqthuScLIVzmykrPc/HqhqyUq+qN6nE0FDAvnK60QGzens3SAwoo
/OmS7nrrUlrsiZd7hCV3DOe44SocpuCJ/MLCXAmPpRNb9eifti4IoXNspJl4UKY=
=exus
-----END PGP SIGNATURE-----

--=-cjIwwdzThmyfIp30ji47--
