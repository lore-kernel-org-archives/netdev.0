From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Tue, 25 Jul 2017 10:42:46 +0200
Message-ID: <20170725084246.GA2860@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <7ccc9080-5967-5728-bb1e-f41b9c91b254@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48948 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdGYKl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:41:26 -0400
Content-Disposition: inline
In-Reply-To: <7ccc9080-5967-5728-bb1e-f41b9c91b254@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sergei,

On Mon, Jul 24, 2017 at 07:40:01PM +0300, Sergei Shtylyov wrote:
> On 07/24/2017 04:48 PM, Antoine Tenart wrote:
>=20
> > +	/* Set the SMI PHY address */
> > +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> > +		netdev_err(port->dev, "cannot find the PHY address\n");
> > +		return -EINVAL;
>=20
>    Wny not propagte the error from of_property_read_u32()?

I could do this, you're right.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll3BIIACgkQXE2LyK3b
vNhKwA//c2z1lXmEH8XSSYUJqD+TluMU0S4Uq78nU0tm2z9SYgwomRmZIqEAozb/
FISFFuCyC4MFnR9j//An+CdOjTxVfW8BiBD3oW5MAyAG7LNhGaQ3+wxcF702iZ80
nuMFtumKY/XSDxWkTQEBlRn9DcLlypcyKotaAc8+16d4AyibjDNLO/Fk8q5/wsmf
08onwWfiX86Ifw7Ip27lswHIrenwB5lcZiJWOvchtSslZAFp59AD0a0S4SgQESKb
kwg7HBocrb8Ni/gL+8NONn8DpCkx0EZtlO//NEShFsiKvpHVmxx1wc2HmxmG/1D7
SIRbB0PbNAgp6TkBFCuhypTkYPr8WUkH+AKFXLzpiKIFuLK0q5Tn0iJv9NH3N154
JfrzYDjBzvUhCp2ghFDDl0xsvzCo6AJmOgGuV3cdwzGdoPpDewNKu9AhGFDeMEv9
MlNfyfGNkXASiYJVzCQxBTb7iZ8tBBmd7CKAhCzyQyhRb1R6zB2cy/vasM1atcMn
hdaQ+MdNG0MaNkIigZlken91rjiYl6Uk9r1YVixCEAl/IxFRlV0mNmI9qO+sJQnh
h2ji1euDDxu4rKcN9Yv1a6SSc8Kh/DxSOFzjCgeLcetpb/6t8mOU/YzbKc7ssyEP
tFGvj9221o3XWC4GZXRh6opl45Utm292xdU4wq6jtoVlHLkMc2M=
=ke4B
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--
