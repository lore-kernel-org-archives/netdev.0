From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 4/9] net: mvmdio: move the read valid check into its own
 function
Date: Wed, 7 Jun 2017 16:43:08 +0200
Message-ID: <20170607144308.GB4173@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-5-antoine.tenart@free-electrons.com>
 <71f0a99b-4736-a405-1d06-9c05f80aa327@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="St7VIuEGZ6dlpu13"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47760 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbdFGOnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 10:43:20 -0400
Content-Disposition: inline
In-Reply-To: <71f0a99b-4736-a405-1d06-9c05f80aa327@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Wed, Jun 07, 2017 at 01:00:21PM +0300, Sergei Shtylyov wrote:
> On 6/7/2017 11:38 AM, Antoine Tenart wrote:
> >=20
> > -	val =3D readl(dev->regs);
> > -	if (!(val & MVMDIO_SMI_READ_VALID)) {
> > +	if (orion_mdio_smi_is_read_valid(dev)) {
> >  		dev_err(bus->parent, "SMI bus read not valid\n");
>=20
>    I think you reversed the valuid/invalid sense in the new function's na=
me.

Good catch, I'll fix this.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--St7VIuEGZ6dlpu13
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOBD8AAoJEFxNi8it27zYndYP/iYpKle9XxWGMcieF36oqdHM
OzgE1DXtPC5DN+lJBRfFBNENFrLDAya/8NmDg9dS2H4Cgy0p5hPe/pxqcdoJC1Mc
IFSKMZCJ7RNrbeJDLurvWh/y6x0+WCHSWpMmjbVp3gM4wqFxtiNTWuLerrhSen5u
s4uxHrcWQeIGh1qzERlRH29WnRCYANhpCNSiGIgGgqtXe1rB7l9dElymtz93cQ6Q
Fyrc55HVkwhfRvlYxhswhtgEzxEoQfOs2xNSctZeHA5Mpxab+xZcvNcWwnqROU/g
eB1sCuBagIHEko4v+PXzdkLt4YXEyT/OhhO4oXWPHzQD0Oh+HxwyDDduTaI937/s
lo9rMm/SfX8AjX6XajmEF8Hul+g79pq8qDX2t/t/Yz7kpOlvJAy+9wmGHhE0toQk
2Zcys/XIOgW6eM+d5SsgZkrEP5MyP/WG+kAg0Bdr+pY73q4hvmckEIuTwTnESf8d
Qjx978mLc2o7jNEHN3vqGYjE7K6tn8EBxqf8sfQDnq/7NOEja5nax15j/pYGgJyH
k4v6/X0sobK801VSgMS0dScXKJxTq7eZ7Moid+PTnWr+s1/ZBJSuzbotZS/2vdyx
gC9DLUUXpQ+xfp2vGbMsXapA0N1BZ31cQkt8Dz9MmV3yJsa6mDJR7RHIe2Km+2Yu
kilAY3gpqXC42/ypiyqw
=O0fx
-----END PGP SIGNATURE-----

--St7VIuEGZ6dlpu13--
