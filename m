From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Thu, 1 Aug 2013 00:11:00 +0300
Message-ID: <20130731211100.GC3737@radagast>
References: <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
 <20130731194523.GB900@radagast>
 <20130731200428.GD8027@netboy>
 <20130731200756.GA3737@radagast>
 <20130731202006.GE8027@netboy>
 <20130731202617.GB3737@radagast>
 <20130731203406.GF8027@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HG+GLK89HZ1zG0kk"
Cc: Felipe Balbi <balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130731203406.GF8027@netboy>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--HG+GLK89HZ1zG0kk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 31, 2013 at 10:34:06PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 11:26:17PM +0300, Felipe Balbi wrote:
> >=20
> > oh well, we can go on and on with this. Unfortunately we (SW team) don't
> > have control over the HW folks. We strongly suggest that they don't
> > break SW compatibility, and that's starting to become true.
> >=20
> > You can very well expect next version of CPSW to be SW compatible. If it
> > isn't, then TI will send patches to add a new revision check and treat
> > it well. We are the first ones to have access to new versions of all
> > our IPs anyway.
>=20
> Okay, so starting with V3 the registers probably won't be moving
> around any more. But at the very least your patch should include
> macros for the known V3 along with the default case.

that's the point, there is no known V3. Once it has, surely we will add
such macros, but until then, we let the driver assume the highest known
revision if it finds a register with an unknown revision.

--=20
balbi

--HG+GLK89HZ1zG0kk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+X1kAAoJEIaOsuA1yqREPMMP/jSL+XObHgcVWP+zCzHm+oSO
WlcU9nEAhdGSAxnDhRJQy9aONcQLnqXD5tRN219ujKfLC4D22NoZ/pTJOsj3lQYL
4Klkiu5zYt48sFMVGvFgFr22wMflOjT14HkAEZ4lP8w/tBrXmV4eRerPlBbtKJPl
nYdhU5IZodCLtnnInKJX2wUtKl0zNcP1oVxq3hd0iMalHSdab98UF6VO8eBenZPT
HVodc4sbHFPrrppSOn3Dh2dCszu9buxcQRr5sQWp4nd4Ixy2ZGRQQ1oJsZirF1dx
8w84MIaZ9pnwvw+qJ4j3Dy9pl+MMrDkwD8IP/S4Cc1z2PnpTbvsHhYqkRM2OlRQm
VagS0j6GU6eI8T30yvFU/OaUBO8N2TW0EDSXXfPRkdvumF4PnrpTdpN2n3+FcXCo
MRiUlCpO61jpj4sRSSsRrgh+JhiA2RwrVTdphZ5zUm02BC0d8IpFmdftMT9ROsXb
nowHx5pXg1eKeBCasFXeWZMGT7vjqWN4SnxSHCAG0aD35bgNrnRRIOhTBa/KAuBb
HWvpTr9JQd76x5zXiqiWJ4FaG1Jk8OTl56qQ707Pt5TWopF1/f058pVjBcQTrhpH
LAiBWLYcGQ7svTOyC9WWFkNBa95/a0TB/ne12KU/awtro0gWsG+cpaADThxO8cDM
O58jWwwy3oPYEK7qSmuk
=GhQ+
-----END PGP SIGNATURE-----

--HG+GLK89HZ1zG0kk--
