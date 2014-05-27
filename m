From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool] Ethtool: Add Altera Triple Speed Ethernet
 Support
Date: Tue, 27 May 2014 21:09:57 +0100
Message-ID: <1401221397.2586.2.camel@deadeye.wl.decadent.org.uk>
References: <1399572919-32198-1-git-send-email-vbridgers2013@gmail.com>
	 <1399572919-32198-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TUn2gVmndy+6Joy7qYEj"
Cc: netdev@vger.kernel.org
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58003 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753145AbaE0UFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 16:05:53 -0400
In-Reply-To: <1399572919-32198-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TUn2gVmndy+6Joy7qYEj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-05-08 at 13:15 -0500, Vince Bridgers wrote:
> This patch adds Altera Triple Speed Ethernet support for dumping
> formatted register output from Ethtool.

Sorry for the slow response

[...]
> --- /dev/null
> +++ b/tse.c
[...]
> +int altera_tse_dump_regs(struct ethtool_drvinfo *info,
> +			 struct ethtool_regs *regs)
> +{
> +	int i;
> +	u32 *tsereg =3D (unsigned int *)regs->data;
> +	u32 version =3D regs->version;
> +
> +	/*
> +	 * Version 1: Initial TSE driver release. No feature information
> +	 *	      available, 32-bits of version is equal to 1.
> +	 *
> +	 * Version 2: Lower 16-bits of version is 2, upper 16 bits are:
> +	 *	Bit 16 - SGMDA or MSGDMA Registers
> +	 *	Bit 17 - PCS Present
> +	 *	Bit 18 - Supplementary MAC Address Filter Registers Present
> +	 *	Bit 19 - Multicast Hash Filter Present
> +	 *	Bit 20 - IEEE 1588 Feature Present
> +	 */
[...]

You need to check that you recognise the version and bail out if not.
Otherwise, this is likely to do something silly when the driver supports
a new hardware revision.

Ben.

--=20
Ben Hutchings
A free society is one where it is safe to be unpopular. - Adlai Stevenson

--=-TUn2gVmndy+6Joy7qYEj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4TxGee/yOyVhhEJAQrhDxAAne+rxavUDE5YmRAWZvQ3NsJMJ6+2KKWa
dkoGnCiKjdes6oXMsjjeDDmmYB3Guq9PBlXIASFvEyOCLoq80+tA/jL8/niqugkn
5BgY2n3hWrOB3GeBTbRX1V5q7GW9eiS6jIDK7X7gS5Ita322YbANS1rGMPswrvX+
Y3heTxrIwV8+cpToxLP1j6PChaLy3onuixIyxwfbu28Ij0L1C7yvS11DpLGgRwzX
MoiJ3Yu2DHq4UqQrsteCXsa669kuTdSqKD2/FRJFrlAQgDk+k9ui5YQr/5QlcLMn
jCo7RDuMaBqFv2mnKLNE0QrMUqsgQQaaIJeU2kZQfa7pbISdXyk7wwFxlE9cUth4
X0481olE5H7bQ3ub//db2DV2h17HRfKFAmh8nOlD0juVp10H3swZOEUhpcfdv0tF
bY2rbMrd1Ab5yz+jgVTm8ic1og6Zc38FjtV3M09cAyko93nqaeV9FqcozUec3lmP
pesW+b1yXkGOh02Bs1weEmbH9zEwdvKosTlwIsbJSqXHDm/fikpx3tPPgsLvZqmp
cR7JBQ7DD4jzR///+CyUJkE1XqK2+uWf7LFAj7vBx20rCRdPcyJimg63+rv90Pbh
+0sDxDtD6brj72n4yAjAQzHUug3YpLPP3NNh5j5ci2tflYcgKk/h5IEZHt/RBxhV
PKkD6Cs0WTo=
=t6BG
-----END PGP SIGNATURE-----

--=-TUn2gVmndy+6Joy7qYEj--
