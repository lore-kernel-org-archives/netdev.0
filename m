From: Moritz Fischer <mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Mon, 17 Jul 2017 09:45:59 -0700
Message-ID: <20170717164559.GA8750@tyrael.ni.corp.natinst.com>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
 <20170715183745.GA28217@lunn.ch>
 <20170715184653.GA28599@tyrael.ni.corp.natinst.com>
 <20170715194832.GB28217@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170715194832.GB28217-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 15, 2017 at 09:48:32PM +0200, Andrew Lunn wrote:
> > > > +		ethernet_phy1: ethernet-phy@4 {
> > > > +			compatible =3D "ethernet-phy-ieee802.3-c45";
> > > > +			reg =3D <4>;
> > > > +			devices =3D <0xa>;
> > > > +		};
> > >=20
> > > Since you don't fully implement c45, does this example actually work?
> >=20
> > Yeah, I've tested this continuously. But for v3 I anyways implmented c45
> > writes.
>=20
> Hi Moritz
>=20
> Just out of interest, what PHY are you using?

Depending on whether the FPGA image is configured either:

- Xilinx 10G PCS/PMA LogiCore IP (C45)
- Xilinx LogiCORE IP Ethernet 1000Base-X PCS/PMA (C22)

in between that and the DMA engine there's a bunch of custom
stuff (will be open source once the product ships).

Moritz

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZbOnDAAoJEL5CEHepFqovIXEH/RY7Xbge/rOCvOO+qpceLdfp
X3hUvgb+ME2mkj9rAUZcKMbnyg8XL33bP9z0AGp/2t/+J0Fsg8r1Gq6voGR6Xtmd
HAjFIO0JyTc+eVNT072WIMFwSlk+WPwl8/BjWx+bf87H6wXOhwUCx+BlVp4fEuHR
MvwYtdmq8Cs0OlcDyd25uCO9PaBEMQ+szWSIpR4711WBxELjXJooYRttVjd4oX8b
GcQ0dHAe+OWhAxEMYKCUvVZrOzqkReEUz6cPH2Xs8BTxDwBBUZYdNzLkFqpNLhfZ
bq0t7a2+Qc4vPyayNdvHaIIAdbEEE5Wu8OywsBkQ6qpVTOvkLaFviRMiYUe77ac=
=axjd
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
