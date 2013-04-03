From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 18:47:04 +0300
Message-ID: <20130403154704.GD19093@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com>
 <20130403134102.GC14680@arwen.pp.htv.fi> <515C3A42.4020404@ti.com>
 <20130403142747.GK14680@arwen.pp.htv.fi> <515C3D94.1060000@ti.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6840397604861865279=="
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org,
 cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org, eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <515C3D94.1060000-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============6840397604861865279==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="iVCmgExH7+hIHJ1A"
Content-Disposition: inline

--iVCmgExH7+hIHJ1A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Apr 03, 2013 at 08:02:52PM +0530, Kishon Vijay Abraham I wrote:
> >>>>+		ret =3D -EINVAL;
> >>>>+		goto err0;
> >>>>+	}
> >>>>+
> >>>>+	if (!phy_class)
> >>>>+		phy_core_init();
> >>>
> >>>why don't you setup the class on module_init ? Then this would be a
> >>>terrible error condition here :-)
> >>
> >>This is for the case where the PHY driver gets loaded before the PHY
> >>framework. I could have returned EPROBE_DEFER here instead I thought
> >>will have it this way.
> >
> >looks a bit weird IMO. Is it really possible for PHY to load before ?
>=20
> yeah. it actually happened when I tried with beagle and had all the
> modules as built-in. Because twl4030 has subsys_initcall(), it loads
> before PHY framework.

that's a bug in twl4030.

--=20
balbi

--iVCmgExH7+hIHJ1A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXE74AAoJEIaOsuA1yqREhR8P/jdBsfIWk5F+FRL20sflOaaH
13di2G7fjFq8smKog+YR48DhMyDSF4wO6l9LK+T9iIbt2jA65YfZ2LgZVXVCSUH1
coqm3yY2tfVGaDWd9s+oUP65sUCJT6Y57HKXIl1VOPex1YAiyESDXW3xT+Y+Cqg2
nzdtKbQexAP+tmFt2mrairEHhO5guWe1O/dFOfPKFScU++bpJ8iMYndEBy9ACqNW
felCwwIQaQHuU+axAgnNdK/Yy0UbEJwVxWMtQ1jcVrNCZQw1UO6xrpkodMJer+4I
98c7zvUb6dtVUfwWCAyGMfkw6uZ8Ydjpse7rmPy7qRsyTg74pfIfgM18iSj5AqKn
zLJ0+00Ij+EiJoPl1JL/JWdGMk3PxBhJBKwQSNXbO4Kbo5c9EiOqycgfg7Wd+4li
hx1YUYk/fQxmELb7ynZdaO9rgEQJ5ogS3p8Juxndr2cVHc89qT9pLJc0QKYrVlUD
BuXwB87cZSppheUeQ1lIOw8GIwmihs/eymLzAwrvoa0KbZfGiUa5Zg1AqLXeJXWo
xG6tFtZdc49xD7kwyiFyQaJ+7FxuOcLE1O6OSuAGN9ODsyYGe6VhyQqDb3rajK8W
RDv4B6cV9dZwOdvN8i3OnQ1Iz0zhAOeeZSoNJeoQEI8X1pt4IH6SVafyu9vG4WtH
nCKnVNuQ1rzUX1AAiEqI
=7PWu
-----END PGP SIGNATURE-----

--iVCmgExH7+hIHJ1A--

--===============6840397604861865279==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============6840397604861865279==--
