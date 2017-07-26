From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Wed, 26 Jul 2017 02:07:03 +0200
Message-ID: <20170726000703.GI2860@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170725151748.22268390@windsurf.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="MZf7D3rAEoQgPanC"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:41843 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751446AbdGZAKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 20:10:09 -0400
Content-Disposition: inline
In-Reply-To: <20170725151748.22268390@windsurf.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MZf7D3rAEoQgPanC
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Thomas,

On Tue, Jul 25, 2017 at 03:17:48PM +0200, Thomas Petazzoni wrote:
> On Mon, 24 Jul 2017 15:48:40 +0200, Antoine Tenart wrote:
> > +
> > +		port->link_irq =3D of_irq_get_byname(port_node, "link");
> > +		if (port->link_irq =3D=3D -EPROBE_DEFER) {
> > +			err =3D -EPROBE_DEFER;
> > +			goto err_free_irq;
> > +		}
> > +		if (port->link_irq <=3D 0)
> > +			/* the link irq is optional */
> > +			port->link_irq =3D 0;
>=20
> You need to add the irq_dispose_mapping() call corresponding to this
> of_irq_get_by_name() in the error path and in the remove path.

That's right. I'll fix that in v2.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--MZf7D3rAEoQgPanC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll33SMACgkQXE2LyK3b
vNjJ0BAAgD9N85kft7ix0bwcDqYqMbPy8S7NxAwG3BTZEFFGxSfKcu9WWiRZ7P7z
aoH1eJcWFk69tRxA5J+udCniDP4DcZ3BMmvGONfs52Y2grQQiA1p2W2A5Iehgy4E
HsAin7SuKz06WX1LCmOA7Z2+U3AMAtqfCfkMaBUni65sa4GdFDAOUTZ5gX50nFoI
kGIUzaw4n4u8pRNt0trJ1KxMOTngdhs1wdLx1iAbpIDpxyerQt9f/6Sp8ZxgkpKc
ip/dkhATAPRIjtTdpzKk6OtPPTt4p5f2h19KtOsn/8rMk3i+QpY4PPhhCvaIo11g
c7MwErymUF2nWxykimLVO2X0rusSZ8JZx6NcvjxWKGL/lOyqCOAd9RXQFWUIornU
+v80HCOzNI1vIS3RYVGbg61/AUfNt12wgD7RNgDxvIHQBznrjAxgpL5E3fudN9hU
fK0yY968tnr98uf99jw974ODmI1sTljct8WPWG+r80XviTZFY6FMNU+62g4ubVCR
86gVER+1XCIB4H30TeNhZ47TqjJq4zjfCfxI4i5PWKKHKSus6cMD8OJwAeXlxtAm
HglK5UcokA/EVl+P+oEQCLBrRTg23Dk8eHjslk7vg0gp/pcWCaBXUnHGfRc1yDfr
edoyfFEuDSB+lS+v0fzPq9/a/KyGBqHPsV5k06qTZbmWBxyjMgQ=
=veuj
-----END PGP SIGNATURE-----

--MZf7D3rAEoQgPanC--
