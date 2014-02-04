From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Tue, 04 Feb 2014 21:51:59 +0000
Message-ID: <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
	 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
	 <1391526492.7871.8.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-erkw525eOGf8jvhLpaE/"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: =?ISO-8859-1?Q?S=F8rensen=2C?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52391 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932618AbaBDVwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 16:52:11 -0500
In-Reply-To: <1391526492.7871.8.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-erkw525eOGf8jvhLpaE/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-04 at 15:08 +0000, S=C3=B8rensen, Stefan wrote:
> On Tue, 2014-02-04 at 10:50 +0000, Ben Hutchings wrote:
> > > This patch allows the use of a generic timestamping phy connected
> > > to the cpsw if CPTS support is not enabled.
> >=20
> > What if CPTS support is enabled in the driver, but this particular
> > machine doesn't have it and uses a timestamping PHY instead?
>=20
> That would not work, the CPTS will grab the SIOC{G,S}HWTSTAMP. I'm not
> sure how that could be configured at runtime, other than a private
> ethtool flag.

Do all versions of CPSW include hardware timestamping?  Because the
condition at the top of cpsw_htstamp_ioctl() suggested to me that there
are some that don't.

> Also it seem as the situation with a timestamping MAC and a timestamping
> PHY could deliver bogus ethtool timestamping info, as it will come from
> the PHY if available, but the timestamping will be handled by the MAC.
[...]

Right.  If all versions of CPSW include hardware timestamping then
bother with PHY timestamping at all?  And why make CONFIG_TI_CPTS
configurable?

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-erkw525eOGf8jvhLpaE/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvFg/+e/yOyVhhEJAQqnXA/9Fu90RBD6+M5Sn+DO0+xMZeFySWp0Tz29
77wp0K1P87FQn8WXjZ6mTTM9bCiiy8KZEg98gY4jU4D09la2SA0+j01ODpc3JLjb
io0/QjMgtYEiZA0iBM9uf3Ed6vbn90H1PJXQNLJf7G+ZwGs1/5rJ/ustDDRDUyaQ
I8TXe1oZStmbzXHJ/q/D9sD/+bqFcmyGJraIeIxF2QbnnZ5kdAHiPrCZ05T5N2ov
/JW9CabbX3bfk5o9z2amUR4xYG0DfCm9BPnX3/nxaMU/w/fpboWBNoIlUEgiLfJE
6CK7LyDdAxO3r0LX7SiviMSVX3IZXGMPo+zQ5g+61ztrQIpTEPwY3bJbBRDM5BZr
nI9vlFk06fTjWVwAGJaNaJ2Hh1qYRfqluSOFeaH+bt09SSFDvgPraFImy+GOdX+6
asZIssr51SJB+JiotV1QgfLfg5rneAw8YkUeSIvdodgPIgg80p6bzODI6p8cGkP1
KKL5aWCYOQZGFyWph5uNDZ0rc8YQ9wKGYKHawpl9kjjNFfKJWMO6Qkss0lBufs/d
enThy+gKX4dMDUNAx/WTOwdF87bSleFYVVTXJrLJIWOKOvUVzuPXKXkETMkI3AUo
X63OQA6Cdyl2foRdCILBBd82YdcK7LHVo6qIjEnDgl7QO2hku3fPIqU61HnASZzh
OlA1vJN9T4M=
=U1gb
-----END PGP SIGNATURE-----

--=-erkw525eOGf8jvhLpaE/--
