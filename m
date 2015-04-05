From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 4/5] ethtool: Prettify RX flow hash indirection
 table print
Date: Sun, 05 Apr 2015 03:00:59 +0100
Message-ID: <1428199259.11260.137.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6FKDBecIumafBdVdMgYQ"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58726 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbbDECBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 22:01:11 -0400
In-Reply-To: <1422193883-30504-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6FKDBecIumafBdVdMgYQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> From: Eyal Perry <eyalpe@mellanox.com>
>=20
> When indirection table size is not a multiple of 8, a new line is
> missing at the last row of the table.

Yes, good point.

> In addition, make a distinction between the attribute name and its value
> by adding an indentation on the beginning of each line which contains
> values.

We've never consistently indented like that, so I don't see the point in
changing the output of just this one sub-command.

I'll just fix the first thing.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-6FKDBecIumafBdVdMgYQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCXYOe/yOyVhhEJAQqnbw/+M+wc6aZxuk21rJbEDtDjUGh91dD+zFHt
3YKDw1SXSNcf/PYZQcNHixlxRFl+Td2ZsnmWcd08QuIW/cIpK4dECdot+ZkBcfQl
qCkA32E6OrFq11qSWvw6DfYqAedbwzzUH9xJwDdBNkvYAtDJ7IT5nntiOtQujo+4
gfxJfF7DLbfGsXEy1aPHfvtXSlAFLHk5zTmU6MVwTtdLlq+YRa6/EpricvwQViLs
wHr5x4jddFW7wUq4ECyb9hBD9nbVMFEMzB6gNH+2T9JwPXxZc302bUoB300aWRDW
Sn+LaUI81i+wlD8kIZSJdyA2W7Bl2OCfeCJoQeWqsKI99OaLFRsli9bXPCA94Hpi
5y7jFEYXceH9qMPzwab+j1aKv0gZ8hZ7WKv32DPwoS7EXKEyitsX4dSE1O2Xvft4
OZzkBLpftfr8PI9TSjp4EQvf+B/upCdUmAYbdd+FE6HVzM3/y7RfJtBb3bgkcTy+
FUdvN7wAfkbrw9GlJKtUggoN2CfumrSO++WaV9PzbhrRIu7yytLFi+YT6RYWrXu7
mOpdG/wWvNR6ysyMILGmEYaw9ZMFU0K6/bkoT3fQ104mj6iq8uu+B+F7L5m9V/G8
r2MpLfBiNvOYW0ckuEBqupJkKWwKPlrqRJLjLWr13J18fckGTb4LmcqjtGKbFX3x
xoG1ueS/UrA=
=rYj6
-----END PGP SIGNATURE-----

--=-6FKDBecIumafBdVdMgYQ--
