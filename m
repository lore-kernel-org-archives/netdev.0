From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 17:39:07 +0200
Message-ID: <1211211547.6252.54.camel@johannes.berg>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2)  <1211032475.6252.2.camel@johannes.berg>
	 <1211117795.686.15.camel@localhost.localdomain>
	 <1211199368.6252.19.camel@johannes.berg>
	 <1211210686.12187.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VVMPMxkZnK+h4toNjr8S"
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1211210686.12187.6.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VVMPMxkZnK+h4toNjr8S
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-19 at 11:24 -0400, Dan Williams wrote:
> On Mon, 2008-05-19 at 14:16 +0200, Johannes Berg wrote:
> > > Instead of testing for wireless/, best thing would probably be to cal=
l
> > > SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
> > > wireless.  Some drivers may have to load firmware to figure out
> > > supported rates and encryption capabilities, but to be honest, NM doe=
s
> > > this to detect wireless devices and I haven't run into any issues in =
4
> > > years using it.  If there are issues with drivers, then we need to fi=
x
> > > the driver too.
> >=20
> > I was about to propose calling SIOCGIWNAME since that is what
> > wireless-tools do and that linux/wireless.h indicates.
>=20
> Hmm; NAME is pretty useless.  That's fine to do, I guess WEXT requires
> that NAME return _something_ at least.  NAME should never ever be used
> for anything more, but since wireless-tools appears to do this that's
> fine.

Yes, I realise it is completely useless, but wext seems to require that
it be implemented. RANGE would work as well but typically has much more
complexity in the kernel.

johannes

--=-VVMPMxkZnK+h4toNjr8S
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASDGfGqVg1VMiehFYAQKFrQ//VJSZe8MOCXjybVqM8xZNrPJJjx+kaT/m
rytyEgVBFsj5ef9VeMruP3cPN/79jzJbWxeeG12TPbCNorsoRKvNk60eVrZw6/3a
AAySbees2kodn7C1OfGgrbe2arQ1mrNsC0Y41CCtL+fkcV0D8tcmx8CBLtxerxqG
yIGFygdxPVFTE8FAO540QInHNGK+6LS7BEPAgs5st7EbmymCDvfvrvJZXZWpgeAW
Svx6ue0gv/GN48R8v/wxyhwY7jK7EDXYV4HCjIz7gstnB8DLq4RuzHYz1uaAInXs
1l4iaqSP2HK891rIiDdMxr33NvWTdmRXjADYCiA8UR2a+iERPBC86XL+5avrh6e5
eSDhi+Q/7v+R+gAYR4uZm6PszLpvIPmPav6XqIn4J+qTzxYrVA0Nr76s51XEqzNY
MMGAyI0F04aCmJQ3xoSQjqVOFUpEnN1gOk53gVNm6Tx7zsww2IQUZWtBPot7lJqh
Gx6tF/vuizl9R2NZ/ELnq5y/m2OfjlXAIyPbkROK3+j1ADjJCZsMbZ2/dahNFpOY
HrddAkztuH3el82LnL8nqC49Fps9yc574RsdtJ7JaFRxppM8VLSEEzxyk7h5GI8d
BkhXH2/HDi5yQbFkhs77Zhr+OdldV5zQOxpcEu+MNtfemyIkO94X7XVNCL9mVxtx
2q9x99ypsgs=
=lRSF
-----END PGP SIGNATURE-----

--=-VVMPMxkZnK+h4toNjr8S--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
