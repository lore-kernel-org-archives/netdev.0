From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [EXT] Re: [PATCH net-next 10/18] net: mvpp2: use the GoP
 interrupt for link status changes
Date: Thu, 24 Aug 2017 12:59:23 +0200
Message-ID: <20170824105923.GF23960@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170726162648.GK12049@lunn.ch>
 <20170823082510.GD5202@kwain>
 <5ebd192c54984b25adda0a294035b1b9@IL-EXCH01.marvell.com>
 <20170823160444.GC23960@kwain>
 <CAPv3WKcSFcd4kBS_vpTsbf789xsLatuT2TBfZZbiu16sRauk7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="/QKKmeG/X/bPShih"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37089 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdHXK7Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 06:59:25 -0400
Content-Disposition: inline
In-Reply-To: <CAPv3WKcSFcd4kBS_vpTsbf789xsLatuT2TBfZZbiu16sRauk7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/QKKmeG/X/bPShih
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marcin,

On Wed, Aug 23, 2017 at 11:05:33PM +0200, Marcin Wojtas wrote:
> 2017-08-23 18:04 GMT+02:00 Antoine Tenart <antoine.tenart@free-electrons.=
com>:
> > On Wed, Aug 23, 2017 at 03:24:55PM +0000, Stefan Chulski wrote:
> >> > When the cable is connected (there is signal) and the serdes is in s=
ync and AN
> >> > succeeded.
> >> >
> >> > > With SFF/SFP ports, you generally need a gpio line the fibre module
> >> > > can use to indicate if it has link. Fixed-phy has such support, and
> >> > > your link_change function will get called when the link changes.
> >> >
> >> > So that would work when using SFP modules but I wonder if the GoP ir=
q isn't
> >> > needed when using passive cable, in which case this patch would stil=
l be needed
> >> > (and of course we should support the new Russell phylib capabilities=
).
> >>
> >> Even if new phylib driver supports passive direct cables connection,
> >> GoP IRQ required for SOHO/Peridot external switch support.
> >> SOHO/Peridot external switch could be connected directly to Serdes lin=
e.
> >
> > So I guess the GoP link irq patches are needed. Should I resend them
> > then?
> >
> > We'll have to discuss how to handle fixed-phy vs GoP IRQ, but I guess we
> > can do this when adding the fixed-phy support later.
> >
>=20
> Please check mvneta.c - you can find there coexistence of normal
> libphy support, fixed phy and link irq for the inband management mode.
> IMO it's exactly, what you need here.

=46rom what I see it should be pretty easy to support phy, fixed-phy and
the GoP irq without breaking anything: if no phy is found in the dt,
call of_phy_register_fixed_link() and if the fixed-phy property isn't
found either use the GoP link IRQ. This way all the possibilities would
be supported.

So we should be able to support fixed-phy in a future series.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--/QKKmeG/X/bPShih
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmesYgACgkQXE2LyK3b
vNgndg/+LWWBOM6bZgWcuq1CXcnS1/wLt7A9ylChEHMHDxWTU8BoN+ThpL3nys9z
RaMZpngaFVzIs+vXstCjVAPP1n1RGB+7Logyu3obdHwCDpQXqe2BMLJeUhANYQbu
u+/WZ5/fqyZUhmbSHpeWYyIaqKzF6mfNGharIOa7Tqxvq4mCN31XwsihWp9MDMo8
LiUCLTyyu5KzV7IOkK5aYHDzJe5z/aUsRhMoybaAr2vGL70sx58hcUTPrARa0nzH
aD/pAJTRL23nLIzcMbh4W3vLTNhA70hESi1W5LfgPAsFfN9bgN7pjkBEFvDQKlkx
36mGLzhuezr2+PIf227/OLTeqEN03RpvNMk6ML/a45F8NIUYp07Z0d4WkFKFfK2W
K3MVg5j9y5XwVc3UTsLcD1bvan1BAC7IluTTsgvmRzyeIkWSErAkmF73+rjrr7Cp
kRom+GEnDg0UJRzOCMiJkoknu8or4n37zWBvN3StM73pXRkA/l1NhVWyZ0EFWY91
xTlNdOaGviyDsVdueSKT/AvhFciIYGqFaIx+WvZc9l1DBduAfvLRUo8rPoc3C3Q2
2xAHfN/Bgr5fVu+Yw3CVREcMKcntmU8546RWw/6iTVGs7OXLHT7AhkZ5Qa4mscsx
NrkNMpfuHQA+inhvdb2KImnXWdvqqBCyQ5E2k4JbgHVfXsJQIHg=
=u2Za
-----END PGP SIGNATURE-----

--/QKKmeG/X/bPShih--
