From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 21:45:25 +0300
Message-ID: <20130731184525.GA629@radagast>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: Felipe Balbi <balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130731163845.GB4234@netboy>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 31, 2013 at 06:38:46PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 06:28:27PM +0300, Felipe Balbi wrote:
> > On Wed, Jul 31, 2013 at 04:49:59PM +0200, Richard Cochran wrote:
> > > On Wed, Jul 31, 2013 at 05:42:26PM +0530, Mugunthan V N wrote:
> > > > The new IP version has a minor changes and the offsets are same as =
the previous
> > > > version, so instead of adding CPSW version number in the driver, ma=
ke the driver
> > > > to fall through to the latest versions so that the new version of C=
PSW which has
> > > > the same register offsets will work directly without patching the d=
river.
> > >=20
> > > This doesn't make any sense to me. Why not just add the new version
> > > number?
> > >=20
> > > None of the hunks in your patch are on performance sensitive paths, so
> > > I really can't see any point in removing the error checking.
> >=20
> > well, if a new revision of the IP comes, the driver at least has some
> > chance to work without having to be modified. If it turns out that there
> > are really different features, then we patch a new version, otherwise we
> > should just assume highest known version and try it out.
>=20
> And if the driver reads junk from some random address due to
> bootloader/DT/multikernel madness, it will happily peek and poke
> around instead of rejecting the wrong version number.

that'd be a bug in the DT anyway, why should the driver have to cope
with broken data ?

--=20
balbi

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+VtFAAoJEIaOsuA1yqREt8YP/0g1SGNhwgjarUHZuOgucHG/
V+B9STCuNWPTJ2zl6+1Mj/23LUmc6Zw/c9A3o3lMXS6OPlIN0a0T0FhB+OnZhpjb
2Qmv/9QOt/1MLvCBTz7oNfFtDDkdEAUWNyi24POvmxI8pNUZJ5DoTqmd+a6JInOR
Fu9fTPkSTzPIS7de4hx33qEwilk8QyxSdc0SzfzkeMqwo4/cFeSoogaNX01eeZ7G
uqJwJ6CgpOYu99xnFYqac2tyUIzsbB6AJ0SVroPYuiNfK/A9SSXCUoFnX+y70DJq
l10f3rM1OymdeC4+0SepCJAWcgNgRHC6SHJEUpibentRSby4lCM63UPGaEbc60Od
t4+aBDuHvnUDntQow5hNjGnevrv8Vd//gVQxbpwwmK6asqb3VwOMwzZfC3/DKaqJ
BDF7QibkAX97xMTGPX7yCHNxxLk50sdso54maT0PPZk5XS1o/AXH1B1HyykuVR6Z
+ldqE+uZ2oeh3kMomfBoOtH38BHkte4JMEpbqrKYH+RiaNMy9jybFJx1th8TAvRX
cEkXFzudsoaas9P9GoSZMnE6tEJE/zf92ohsNnt2LM34+R6O/VdMCbG5YL0qY2Yw
nlhhsbGb661OonWtbi+AOQJdf4jj1+0xJkvNZgBNENVhEHp+qhQOseQ7b4Cu8o55
39TAjFlAYmlEcPMmcf2X
=KKEM
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--
