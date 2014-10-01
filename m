From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Wed, 1 Oct 2014 12:43:18 +0200
Message-ID: <20141001104317.GB1261@katana>
References: <20140930144950.GQ1325@katana>
 <542AC5B2.9040406@pengutronix.de>
 <20140930152550.GR1325@katana>
 <542AD483.2020808@pengutronix.de>
 <542BBF3F.2040803@ti.com>
 <542BBFBE.90406@pengutronix.de>
 <542BC42F.2010406@ti.com>
 <542BD116.4090809@pengutronix.de>
 <542BD3A7.5060200@ti.com>
 <542BD6F1.2020900@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dTy3Mrz/UPE2dbVg"
Cc: Roger Quadros <rogerq@ti.com>, wg@grandegger.com, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <542BD6F1.2020900@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dTy3Mrz/UPE2dbVg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> > Unfortunately it is 5 ;)
> > We have display IP related bit in between 3 and 5 :P
>=20
> What on earth were the HW engineers thinking????????????

"Let's test my RNG on the bit-placement of this register" :)

> ...if we just have the instance parameter in the syscon phandle, we have
> to put the mapping into the driver, which makes IMHO no sense, because
> you have to touch the driver, if there is another SoC with the DCAN core.

=2E.. which would be my preferred solution. I think new SoCs should have
some kind of:

	compatible =3D "commodore,c64ultra", "bosch,d_can";

in the DT anyhow to allow for SoC specific quirks/adjustments. And
custom raminit belongs to that IMO (see the ti routine getting more and
more specific).


--dTy3Mrz/UPE2dbVg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUK9rFAAoJEBQN5MwUoCm2aFoQAKsP/o5DSh/b9Tgb1sgw6Gln
zGfWweBumR409OyTvdBe0Lqemv0PX2+Mux6H8pZTqQAjx6l3evpSdwXcUcPMoLFU
lUvpN1UR2v6ZXv9DjprkRKHuwABUQGEzoK8UKPyfv3YmIN/nBNxnwjn3uMscfItQ
8d/gKyg71fh0XMQPVyITYI0Ehv3C7foPMj30UxZ/I/LwYzkWErbPey8fiSu7r5FZ
Ut3ln7jZ1hHk7pfoBZhg8kFv2eEWP18yD7G2Wb0kBLfueb6jXqmMLeXVWPGNoc4Y
ISajtZicetXwjvoa6Upxl+RECGRLFeDk5dlIdA9IOonwd3o6RSjVqVMOHOmniEMG
Edi4NQekLMwYDh+3gswWni17oUsro+Gx1cjbnvpfizfFB1OdTuKJUOnayXcdLIKu
ggWRUVlPn2fX2ofm1tucU2GKqxih9LUvY8FOICGoHNwK2aoPPabzOG9DclGJk1JK
bOaY52kKPCkk/rRtxF/WRNQjJ8p9w12qposcbbJc9FyAs1oTe2kFLrL9e+Qm9n9G
SO054zMHFtVDcAe6AQRh1FqHPQQR+doCFlIGZbqQMXvOYlE76ZGka/pzobHB7J/0
FnStB8ZuEZlDAKsysrvgsAr6vKdMjxePag4lM++4zLX2JoC4zcOPbaW3ym8/kdxc
lHW7yi0Dlgv1JDhMu/pZ
=rjA5
-----END PGP SIGNATURE-----

--dTy3Mrz/UPE2dbVg--
