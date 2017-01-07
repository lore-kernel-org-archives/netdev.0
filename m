From: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional for
 dsa2
Date: Sat, 7 Jan 2017 21:31:09 +0100
Message-ID: <0d1c2cf0-805f-cb88-c19d-9faadfcab33e@kleine-koenig.org>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bWORpIEATj1VQgn3RsHPwLcng6qDxPl7O"
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.kleine-koenig.org ([78.47.169.190]:56666 "EHLO
        arcturus.kleine-koenig.org" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761530AbdAGUke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 15:40:34 -0500
In-Reply-To: <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bWORpIEATj1VQgn3RsHPwLcng6qDxPl7O
Content-Type: multipart/mixed; boundary="TkedTEx99LaUde5j23qeat4kqQdIFw7NG";
 protected-headers="v1"
From: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
 "David S. Miller" <davem@davemloft.net>,
 Florian Fainelli <f.fainelli@gmail.com>, Andrew Lunn <andrew@lunn.ch>
Message-ID: <0d1c2cf0-805f-cb88-c19d-9faadfcab33e@kleine-koenig.org>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional for
 dsa2
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
In-Reply-To: <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>

--TkedTEx99LaUde5j23qeat4kqQdIFw7NG
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hello,

On 01/06/2017 11:00 PM, Vivien Didelot wrote:
> In the new DTS bindings for DSA (dsa2), the "ethernet" and "link"
> phandles are respectively mandatory and exclusive to CPU port and DSA
> link device tree nodes.
>=20
> Simplify dsa2.c a bit by checking the presence of such phandle instead
> of checking the redundant "label" property.
>=20
> Then the Linux philosophy for Ethernet switch ports is to expose them t=
o
> userspace as standard NICs by default. Thus use the standard enumerated=

> "eth%d" device name if no "label" property is provided for a user port.=

> This allows to save DTS files from subjective net device names.
>=20
> If one wants to rename an interface, udev rules can be used as usual.
> The sysfs phys_port_id and phys_switch_id also provide physical data.
>=20
> Of course the current behavior is unchanged, and the optional "label"
> property for user ports has precedence over the enumerated name.
>=20
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Acked-by: Uwe Kleine-K=F6nig <uwe@kleine-koenig.org>

Thanks
Uwe


--TkedTEx99LaUde5j23qeat4kqQdIFw7NG--

--bWORpIEATj1VQgn3RsHPwLcng6qDxPl7O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEfnIqFpAYrP8+dKQLwfwUeK3K7AkFAlhxUA4ACgkQwfwUeK3K
7AnBGAf/fvFNdqQezEYZod6ad9K+YkRO8nyaIHARyiQsI56AGikCxKR5QAu8CU2j
Nd3jiv3m8C3SZ8Ph88FLFlmMbc2U3RV7gvdkVBMaaZIfvJA3kOPPLcL/9g7zjXh5
8HKMNu2OMG7wjn+4pbh9Tnwsl0SwGbUGPLro+iH9OeIrsDYQZkxWPHJWT04WPgYl
XiaZ8sgw32bS8kiP6bUXR02X4V9/+z22ResO/oDPp9jMQbFtXhQCZWhOcIU37q+4
oE8wW/KMxLZWL7Hy0s30Un7BALZSEiJ1Pxi/UuFeBlP4VbTsRpGno0COavs+W3+L
LxOtvxvFlFgh93LO42L2Ik+/56obUA==
=kVlv
-----END PGP SIGNATURE-----

--bWORpIEATj1VQgn3RsHPwLcng6qDxPl7O--
