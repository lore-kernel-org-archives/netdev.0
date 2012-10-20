From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: fix concurrent accesses to PHY from watchdog and
 ethtool
Date: Fri, 19 Oct 2012 23:47:34 -0700
Message-ID: <1350715654.2213.22.camel@jtkirshe-mobl>
References: <1350650688-29293-1-git-send-email-ffainelli@freebox.fr>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-g57rM53tz/OuSg4SV/TC"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Maxime Bizon <mbizon@freebox.fr>
To: Florian Fainelli <ffainelli@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63063 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308Ab2JTGrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:47:37 -0400
In-Reply-To: <1350650688-29293-1-git-send-email-ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-g57rM53tz/OuSg4SV/TC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-10-19 at 14:44 +0200, Florian Fainelli wrote:
> From: Maxime Bizon <mbizon@freebox.fr>
>=20
> The e1000 driver currently does not protect concurrent accesses to the
> PHY
> from both the ethtool callbacks, and from the e1000_watchdog function.
> This
> patchs adds a new spinlock which is used by e1000_{read,write}_phy_reg
> in
> order to serialize concurrent accesses to the PHY.
>=20
> Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
> Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)=20

It does not appear I have responded yet, so...

I have added this patch to my queue, thanks!

--=-g57rM53tz/OuSg4SV/TC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQgkkGAAoJEOVv75VaS+3OHf4QAIWwxBK7RvN3e4u3ury2zooo
8M4oLTXMfJq47O5eiFTOnAweYyll68KI4zeGoizGaTNt7kQsFIhdMoE2bUzDgzN+
RR6mCRe/dJI+0uVFhBUm+i2+0riISayKoYEDumUyUWV1DTw6tn8e2NJjPNxkXjYT
CGX7kRr0IzepDujJqplLeCIps/LCf/TxGbHcvuMFgl3VOSFMv9fQlDM6E/ogK92q
IwfM7In8byuxoMeDxxjyqY9gqG4DTZ+5z021uULbiNv68yJjjXgomGFU1VfLhbz8
ruxCUnpVZiXszW1uO8+5H6XPJlxrT5pNZ+QWYkafa1vjANb1If3tUMJBbIP0So0n
cOvUWSvpV5TziTShsiZwE7mGEhC6jOmvOnlS1/JDDyZvTTUyNBZ0ikoA7/qg/D37
2XwibVJHQi4mTuuouQ3ThF/Ux4ckeJ7UDZtEG0Qkc02txYdKfIhMEpbFeH27o7qf
fHcZa+qRGcWesqWo0SoFfyCpIh1CmFRw+IaPwlsrknOoPdvcUqf4cJAgvH+AACK4
db5BGED+DPvq9h5IXRG4SNYgiSOv3B4ntF2TivQknHI+kJ/qBpFG0Oxup6FSBU63
yH6pEZUQ3DbVzeKnZkwBMow4UwF1VQc77zC80unIPbd/17qc2qZFkT0IbP11FUjL
Aidx9TEdUP6tXMOFrMie
=3zWn
-----END PGP SIGNATURE-----

--=-g57rM53tz/OuSg4SV/TC--
