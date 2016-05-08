From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] net: phy: add ethtool_phy_{get|set}_link_ksettings
Date: Sun, 08 May 2016 01:13:05 +0100
Message-ID: <1462666385.2634.1.camel@decadent.org.uk>
References: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
	 <1462622397.19332.28.camel@decadent.org.uk> <572E72A2.9010004@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MtbPnP3SkCoX1XEzlVxM"
Cc: f.fainelli@gmail.com, fugang.duan@nxp.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54490 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbcEHANQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 20:13:16 -0400
In-Reply-To: <572E72A2.9010004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MtbPnP3SkCoX1XEzlVxM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-05-08 at 00:56 +0200, Philippe Reynes wrote:
> On 07/05/16 13:59, Ben Hutchings wrote:
> >=20
> > On Sat, 2016-05-07 at 01:18 +0200, Philippe Reynes wrote:
> > >=20
> > > The callback {get|set}_link_ksettings are often defined
> > > in a very close way. There are mainly two differences in
> > > those callback:
> > > - the name of the netdev private structure
> > > - the name of the struct phydev in the private structure
> > >=20
> > > We add two defines ethtool_phy_{get|set}_link_ksettings
> > > to avoid writing severals times almost the same function.
> > [...]
> >=20
> > I don't think there's no need to access a private structure, as there's
> > a phydev pointer in struct net_device.=C2=A0=C2=A0If some drivers don't=
 maintain
> > that pointer, they should be changed to do so.=C2=A0=C2=A0Then they can
> > use generic implementations of {get,set}_link_ksettings provided by
> > phylib.
> If we could use the phydev in the struct net_device, we could write a
> generic function for {get|set}_link_ksettings. It's a good idea.
>=20
> But I've quickly looked and a lot of ethernet driver use the private
> structure to store the phydev. If the ethernet driver may use the
> struct net_device for phydev, do you know why so many drivers use
> the private structure ?

Maybe just because no-one bothered to update them after it was added to
net_device.

Ben.

> If everybody agree, I can send a new version with a generic {get|set}_lin=
k_ksettings
> and a update of fec to use the phydev store in the structure net_device.

--=C2=A0
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.
--=-MtbPnP3SkCoX1XEzlVxM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXLoSRAAoJEOe/yOyVhhEJMtwP/jxY762FePxuDqbBOHkfpTz1
Bx7AHqB/Hy6oEwGWspLvgO+mMmpSmnWKQed6hyi70X+LaFjD9avzCrP+nRFTnobm
EegrDhoRGzNYVD/nAk+mHC7OhpkhDODbUm2Hdc3RRaxK2b2LZJW1LKDefwiZ/Opx
7QGTwCp1GqPYRJZaTJdrrDANf9/EHFsFPSBKRYGS/V9flgYLoImllwZ3t9sUxhVi
NA2Oigw+CL39+kMGLLFmP67l1vj9b5D/Prf4G77AvVFHh5ejKg+Aw7y+uA3rHg9s
wxrJ2Nlc9kpcMPSUi3I+96lj/4ScIs9JKieRmY1WippZ21lw3dV5YfAiA5EkvquW
mG1UTdJd04SwCA5ZjUZ1M8T6w+zmTg6KRERA8Dl2nz/U6GOj03pk63H/gv8O+j2F
OaRXjxrin82NS4VIL/2359sAwgfUZAfudPhJIYpKcxIPxzitX08ggOWHkZC9l6Pj
Z/vJXjJMXR4sARoZYH9oCpsGccdXNYsQhzt9IR+aukMS+KG9Qs5VdjEWLk3He3EF
3BGDseMX+VvHT2IlaigeV3Qsn++flifYUxtgjsclpu6DVbnxd947BPCku6Z6Iz8+
RBudupBPUv6k5W60RVIRveOUEhfJQKdhtVYdxB6WJIl6En7JFBCHHoJglG3NFy75
nQOa1w/9+QX9bQ6TDeup
=VOvp
-----END PGP SIGNATURE-----

--=-MtbPnP3SkCoX1XEzlVxM--
