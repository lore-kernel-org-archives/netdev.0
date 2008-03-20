From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig symbol
Date: Thu, 20 Mar 2008 19:35:35 +0100
Message-ID: <1206038135.16475.148.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0FES/eduH35huO1gJhWo"
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080320181310.GA17884-QabhHTsIXMSnlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-0FES/eduH35huO1gJhWo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-03-20 at 19:13 +0100, Sam Ravnborg wrote:
> On Thu, Mar 20, 2008 at 03:34:55PM +0100, Johannes Berg wrote:
> > In many cases, especially in networking, it can be beneficial to
> > know at compile time whether the architecture can do unaligned
> > accesses. This patch introduces a new Kconfig symbol
> > 	ARCH_CAN_UNALIGNED_ACCESS
>=20
> Can we please have a single symbol defined and name it:
> HAVE_*
>=20
> Then the architectures that HAVE this feature can select the symbol.

Sure. Where should it be defined? arch/Kconfig?

> This follows the suggestion as available in
> Documentation/kbuild/kconfig-language.txt

Guess I haven't read that in a while.

johannes

--=-0FES/eduH35huO1gJhWo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+KudaVg1VMiehFYAQJ7ig//byJi8CKfE/7515uLj4GdSidKrvL6LGt4
QcEahi7hVp4CIXnD0l8bIvWQEiqjjSrkVMMetC8aQxtUa6hqh02BLIJsqLZxpomv
/gKtks9bRK5JsABLejd+Q+OTjQL7zPlaaN1Rawj2XvJu+OkjdbHwzkIroEswnHzJ
9SzCZwAfuoVh6DYsgxfeWxPEbCUrOLy1gqRQTUau4fR2Tv1qA0Wdlfy3z18AzkZQ
/dULBvQPqsdoEt8/4V0iw36oKdaCPFCKDKhTurEZRKDTiuJM04enMPCXz8S8cfzY
Cz+L8a7jHNHfqMEAlw15Tut+STjK5F+wIPTSiBdunhsEMmHkc3D5ggnY+yLiqbT1
jXXONx52+Fk8wk9iHkppQEzIUTou/vkBXa0RQR/sEXk7SiAZQaerND5QWL6UyHtR
grdGFIZ1VIq2Ug8ld5RkVLuHW0loAlLoR5W3+q5T3/apE6jgCBvZtfKURmbnKeaQ
gLEynMdfHGh67LQvkt9smfh2ejWr5EALKepDwBlSrknX7ar2KxyeFv6RoeWG0EAN
vZTaIlQgYTKmfGA5oB4FW/HJ+6Ha4H9qxPMOmyVQ7vNxVCBT7YxldqzPnAx6i1gp
XQ1JdJ4FkUrLkrXvx4l5mmlZALPkpWhdmrvvaUYdQTydN5i9zUyLCeuAXa2uGbw1
LTCPv2yD58Q=
=fWRa
-----END PGP SIGNATURE-----

--=-0FES/eduH35huO1gJhWo--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
