From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: How to set the filtering rules for drop the packets
Date: Mon, 21 Apr 2014 12:49:04 +0100
Message-ID: <1398080944.3624.99.camel@deadeye.wl.decadent.org.uk>
References: <35e52a86.138f1.14583b52f31.Coremail.mstian88@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BNfHk/lnK6+ezcd7xH1v"
Cc: bwh@kernel.org, netdev@vger.kernel.org
To: mstian88 <mstian88@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49970 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906AbaDULtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 07:49:14 -0400
In-Reply-To: <35e52a86.138f1.14583b52f31.Coremail.mstian88@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BNfHk/lnK6+ezcd7xH1v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-04-21 at 17:54 +0800, mstian88 wrote:
> Dear Ben Hutchings.
>=20
>=20
> I want to discard the packets (srcport=3D=3D80  or dstport=3D=3D80),  how=
 can
> i do?
>
> eg.
> I set the rule for discard the packets that src port is 80:
> ethtool -U eth0 flow-type tcp4 src-port 80 action -1    Success
>=20
>=20
> then set the rule for discard the packets that dst port is 80:
> ethtool -U eth0 flow-type tcp4 dst-port 80 action -1    Failed
> the error info is :
> rmgr: Cannot insert RX class rule: Invalid argument

The sets of fields you can filter by vary greatly between different
drivers and network controllers.  It looks like the driver for eth0 just
doesn't support filtering by dst-port only.

Ben.


--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-BNfHk/lnK6+ezcd7xH1v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1UFsOe/yOyVhhEJAQqLEQ//dPhuyxeFxbYDcE8U+qHkYb5Nx5r8br7L
k3rWeZtL6ckll+HynO9lLU34Gh0rm0noxEANNL7HT15DABeOFEwgLVtMDfHvpr2f
FWxBwmTMZd74Z/Su764aM+q4woiQRQtESEzdVfZRd/lrvQiNy0z3kift0yCYDj4T
qlxLPPhjro5MPA0G2O3SAsIh6WTOirnZI2GUNKbIQCsGtl0uGsbDiEUrkLcFBb9M
Jimmu0vobGtilR+gyg+ZmFkFu0NtkhewLtnLepZF93ehA33DxgZKrc0fZkjxmMnd
ExG3tP/vyOOmyaj8eecB0zPcu/lM4SJB8/3nxG692m3/4ZWRlr1zItsd63aacLYe
wblwqgwhCquXCDblMutVwW8zq55ExftvapphyENkwBfy7wCSjggHAz2sIKHPFis0
9CVJy7iGilPK86J1UjgV1H9cGmKiU99MrYrbFENEaQ7u3M/UFxtY7kJsmy4R42oU
aroM2dD42BF6zFQlwiy7AKaZd2IQklGVBGzTl+FlbJDu50S+L45/aHWaLYbXaJQ2
QpRjBO1GYkr5MOvONOZeyK3SzDRo0FHcfmQB054E9yMz2yGmvZBtbuDJizBCSN9G
biLUcqE+DJmySS6bsRrHyyCB6oHrMzWRuWOSuk8svRFsEhN5fXtZ2ZSycH3ECWSK
3swpqE2XIaY=
=EioH
-----END PGP SIGNATURE-----

--=-BNfHk/lnK6+ezcd7xH1v--
