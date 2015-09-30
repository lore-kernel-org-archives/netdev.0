From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 11:32:19 -0500
Message-ID: <20150930163219.GN32625@saruman.tx.rr.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
 <20150930161925.GJ32625@saruman.tx.rr.com>
 <20150930162046.GB2627@mtj.duckdns.org>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sy9WyBOsCRoUO165"
Cc: Felipe Balbi <balbi@ti.com>, Christoph Hellwig <hch@lst.de>,
	Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	<target-devel@vger.kernel.org>, <cluster-devel@redhat.com>,
	<ocfs2-devel@oss.oracle.com>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150930162046.GB2627@mtj.duckdns.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--sy9WyBOsCRoUO165
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 30, 2015 at 12:20:46PM -0400, Tejun Heo wrote:
> On Wed, Sep 30, 2015 at 11:19:25AM -0500, Felipe Balbi wrote:
> > On Mon, Sep 28, 2015 at 03:35:14PM +0200, Christoph Hellwig wrote:
> > > On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> > > > this (and the other helper below) could be macros just fine.
> > >=20
> > > They could, but they shouldn't.  Inlines are always preferable over
> > > function-like macros.
> >=20
> > says who ? And why ?
>=20
> Documentation/CodingStyle

container_of() is type-safe, what is an inline function bringing as benefit=
 ?

--=20
balbi

--sy9WyBOsCRoUO165
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWDA6TAAoJEIaOsuA1yqREYikP/3MIHqrgUD+YpBrbNLwnWT+B
yuq5be9al7S4Zx69gx+S6n1/6aJqkt6R/42GduhZW2baWe2c+jNmG+P5CRSWgSCY
EHD+NNBUQ07Gm8ttVSVPRcTxApzvk6pWe/G4lXcjvvdhXbezZVsFqxCByBkCH+Rr
OQH3FCtbs2Wm0lxSj//1TjUR5SX7D27G6evN08EnkjGeIJKHXojb37QuDPpn3/ig
mSxmAyX5dyNdOtzzuWVMJ5YPuSvH+Irzp83luYmWzbDczhCLFFCP8mNSgVzinEL6
6XdDvsi7TcUSefIeDO2YkXDjkHqBmCjY0a566csXscOTZolT+HE4OIzGsdzV2xfw
8j3B98Tj11I3o+lIGlZ5y+oxZwirdbJKteKFrs5lhZh4vrrVaky2bB/B33F0IPtK
RvCF4ufQezZPaiRWV7lOhDiY0rb3y9baKaWF7cuvcyxxxrOAX9ieB6HkaDz9dZq7
4l5LGxSXg/hY89ANrZAN6Exlmz70kDr76qEX60za0N7Vn0ZbY48psqZ8i+NMPvfb
JYWq6u6D+ypMi1Hs/C03jBEBWasjQzxbL8UR4DblouNgcTa/OiN56/YlfkdbhyNd
QNsESYmqJ4feH1A8m0Fda0Hg2V2OVuYquwnjV8Nn7EfqGQ8B6qnLYINR6sVq4q3Y
2JUr95okCbfCiT6NVOT4
=Atq9
-----END PGP SIGNATURE-----

--sy9WyBOsCRoUO165--
