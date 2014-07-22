From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Tue, 22 Jul 2014 19:50:25 +0100
Message-ID: <1406055025.7427.7.camel@deadeye.wl.decadent.org.uk>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>
	  <1406050268-13329-3-git-send-email-_govind@gmx.com>
	 <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>
	 <alpine.LNX.2.03.1407230004150.15542@ws.cisco>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hiKdhT7rsmDVvjh+hfE1"
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42804 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756316AbaGVSuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 14:50:39 -0400
In-Reply-To: <alpine.LNX.2.03.1407230004150.15542@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hiKdhT7rsmDVvjh+hfE1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-07-23 at 00:05 +0530, Govindarajulu Varadarajan wrote:
> On Tue, 22 Jul 2014, Ben Hutchings wrote:
>=20
> > On Tue, 2014-07-22 at 23:01 +0530, Govindarajulu Varadarajan wrote:
> >> This patch adds rx_copybreak support to ethtool.h header file.
> >> This is used to show/set rx_copybreak using ethtool.
> >>
> >> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> >> ---
> >>  include/uapi/linux/ethtool.h | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool=
.h
> >> index e3c7a71..d2912ad 100644
> >> --- a/include/uapi/linux/ethtool.h
> >> +++ b/include/uapi/linux/ethtool.h
> >> @@ -433,10 +433,12 @@ struct ethtool_ringparam {
> >>  	__u32	rx_mini_max_pending;
> >>  	__u32	rx_jumbo_max_pending;
> >>  	__u32	tx_max_pending;
> >> +	__u32	rx_max_copybreak_pending;
> >>  	__u32	rx_pending;
> >>  	__u32	rx_mini_pending;
> >>  	__u32	rx_jumbo_pending;
> >>  	__u32	tx_pending;
> >> +	__u32	rx_copybreak_pending;
> >>  };
> >>
> >>  /**
> >
> > No, you can't rearrange UAPI structures like this.
> >
>=20
> So I will move these 2 variables to the end of the struct?
> Also in ethtool-copy.h in ethtool.

No, you can't do that either.  Basically you can't change the size or
layout of any of the ethtool structures.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-hiKdhT7rsmDVvjh+hfE1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU86yd+e/yOyVhhEJAQo9OQ/+NWKOTiKtPtrYzzNXDTEJKlFrKv730q/A
ht6CWvxAL/XjX/wtbepVrRmXrlZuCf9JMdjfL9BOB2SULcVbwRtzG+/jKhBBckVZ
iq0QgMTmnGxojGJ204eTRlz7YViFoEnpRgPy+DOKV2hO+DAUbLeBtKIjGRvuboD9
+a5S8jB2xLCBGZ/biUYJb0yK1oFepEMMRl6Xv0dHVd6B/XMKw2a8HJZJYVekdJl2
KIbBBRlMmO1eNhY5llnl632zPpGsp6xrV0OWEYIinvj6mYojI/2GF+DXUR9639bl
Cx3w+cebZIcKwMbBZ0YHL2sFUgSiuuvll9UR3v7MCL7yH3dUW8fmQ0ZH40A2LpIi
qS2WFfSjMWm9UIYxR3yJNi8PjgJllD9Mt1CahwXHzFozi+CEcLL2GBpeRgYqTOmK
NuE/wR89qSSkE/BCtxHHuNr61m5aIj2kOWqqDkAd7D7ao9/Undn56I1aLIb82OSu
FcV3Am92EM5N027Vs6lmLPjHwQVwVlVcRCKFd2cAtJLXm4dZOPN+A8Xtf0ox7wjS
0h/6mNUcdQI1e2Kv+NljGgOXaHyXrxplR8g9Akt4giWOG0Rp2byRQjKrfHj/D/bJ
N/IgQFgDtGAefn50yEs+d3YW6H9Huq7VZYtfB/9GgKF5epna6uIDZxKGPXqmXe/G
Z35rFn+73qY=
=bzeD
-----END PGP SIGNATURE-----

--=-hiKdhT7rsmDVvjh+hfE1--
