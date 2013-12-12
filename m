From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 1/2] drivers: net: cpsw: fix dt probe for one port
 ethernet
Date: Thu, 12 Dec 2013 09:44:58 -0600
Message-ID: <20131212154458.GA31694@saruman.home>
References: <1386821345-30555-1-git-send-email-balbi@ti.com>
 <52A96F9F.7060801@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: Felipe Balbi <balbi@ti.com>, <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52A96F9F.7060801@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Dec 12, 2013 at 01:41:11PM +0530, Mugunthan V N wrote:
> On Thursday 12 December 2013 09:39 AM, Felipe Balbi wrote:
> > From: Mugunthan V N <mugunthanvnm@ti.com>
> >
> > When only one port of the two port is pinned out, then dt probe is fail=
ing
> > because second port phy is not found. fixing this by checking the numbe=
r of
> > slaves and breaking the loop.
> >
> > Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> > Signed-off-by: Felipe Balbi <balbi@ti.com>
>=20
> This patch is already applied to net branch and its commit id is
> 3a27bfac17fe375539c4e0a53478679645eb5ae2.

Ok, cool. Should it be backported to v3.12 stable tree ? I can see it's
applicable there too.

--=20
balbi

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSqdn6AAoJEIaOsuA1yqREhIEQAJ2Tr3WJhAsFUixl41XBCl3+
KM6nm+IeZY1tlnDFoTpGQu7q0J2k099q0xeUOE7/OMdcWk1bw9Jc1Ii3MiCno+d5
IvLDWJ+ixFS1T9cLqn+e4QYxqCBf10ZaCpq/3OE2e9Nb9ya2wNNq7iEEnOFl2RHi
rAY8RgQF5bXQ5e6TS8/5qydupsp9RglOa12k8T7ja+IA/+z4HB9n1PTO0Q8mXFIb
Y6455R5DGwsxfVFRJemoK9pi2MXPvNS3Np7q26jhFZy9InJEKWEz8CM0rfw2Wj93
4nbo2HG3ps/VrRmLIGNPRcZCTs6oE4ev1G8buFdDYuEamuiUAT3SaIn8BtTPJSZb
yn26oaDmuEW4I53IMzKC3f3pKtzgIGw7NfbZBwOJO/bd4KxPi6KjIT3cdSJOLCPV
+ENtPEsXLEe8M1L/e1MG4uf1kNVFA9qY4lOysITVtf5/stxIHOZbhIPPEdYZfDAl
NzF4wp9iDdQlDAh8xirovr+Fd4NTuLYmPeXMzkk5DJixyhjYE6juf2B4/rCKbK4d
YpOepvLTTBHLb8tDTkZSAIHYhbKL4f84gMfR4DmBTfWv5pnOVPl25+JngT9zL+TI
/tjySoB/bg3XtyMVQzZ8POVo2zJbLri+vY0qYQgxUGNWHnOD2ZV6ev5GdCTsA/HH
7pOL+6WXSU37B6d8Qpqg
=3Hjl
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
