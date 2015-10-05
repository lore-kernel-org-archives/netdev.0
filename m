From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 5 Oct 2015 18:28:58 +0000
Message-ID: <8BEA1895-E543-487C-B2D6-E454555AEB61@intel.com>
References: <1443185758.4674.44.camel@infradead.org>
 <CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
 <1443464822.4674.109.camel@infradead.org>
 <CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
 <1443468381.4674.115.camel@infradead.org>
 <CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
 <CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
 <CALx6S35f8hWfBktvou9B41EwFoODYZJZyfetOdLmeeLcuMHT9A@mail.gmail.com>
 <1443510778.4674.123.camel@infradead.org>
 <CALx6S35Jg1fOCkXM3zkzPW=GbKV0Ake5NKc8iq2CJ255nKJgag@mail.gmail.com>
 <1444043817.4674.162.camel@infradead.org>
 <CALx6S34LzN5z3r3U-N_tu_xpzuohiVu1B9-NO5neyDhbmJ20BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_DF189946-87AD-4F5E-9AA1-6ACC9EBD2A68";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7956 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbbJES3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 14:29:06 -0400
In-Reply-To: <CALx6S34LzN5z3r3U-N_tu_xpzuohiVu1B9-NO5neyDhbmJ20BA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_DF189946-87AD-4F5E-9AA1-6ACC9EBD2A68
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Oct 5, 2015, at 9:23 AM, Tom Herbert <tom@herbertland.com> wrote:
>=20
> 4) To help drivers for devices with limited offload capabilities we'll
> define a helper function to check for typical restrictions (.e.g. IPv4
> only, TCP/UDP only. no encapsulation, no IPv6 extension headers,
> etc.). I am working on this helper function and will send RFC shortly.

FWIW, ixgbe probably won't use the IPv6 extension header check, because =
I am working on simply adding offload support for it. It seems to me =
that if segment routing becomes used, in some places there will be =
enough traffic with it present to want it offloaded. Well, maybe ixgbe =
should use the extension header check until I get the offload support =
done, but that is it.

Are there any good tools for testing IPv6 extension headers? It seems =
that it hasn't been tested up to this point or the ixgbe problem would =
have been noticed, so it would be good to introduce a good tool to test =
it properly.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_DF189946-87AD-4F5E-9AA1-6ACC9EBD2A68
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWEsFqAAoJEDwO/+eO4+5u31cP/jyEbe4GaIbhdkq24CQYdB7K
Nuw4aM1B5CjRKv2yCdkqz+4Ag3WhL2VgI0T5MwEF0esPxDTgX42PqVWLwlystO+i
nlaz7nPHH0MdLqEnS88PxrqdDaeL3NIcxXU4UKRhHe8A8I8S/vY4c1UvR3nHtLTZ
yi0KjB0WEDGaZA4NmacyWLA3BUVqsE6S0HYcu+UGDjqTW59VHDJ8cxeKFk1RyphG
7HEV9vjGCecM0UFDZqqxAnXmT5Zq7Kd6cRxKuf8LIXluAA45LWbP4yL1AqMXLORB
FNGkRhwsRXTTQY6ZUiy6QVHMcTv8sHGFn7akJlDa5U+i+wYWzRMUokUHc+jaskfS
yV1WwenCdzRNNiluG80Vw5inOp7/0fb2g3K9Ammb7CgF7ASVKuldQjiO3nQk0aeo
y4VL8hUe8TLK5hpTrI1+sinDv2uU4nzGLcQ4Krtez/VSDzXjO5cbTnuXc926liy+
d2Qt2paBvLobYMSuG5m7q9iFNxz/T4lYJlLT4LsGV5WXLln9NN2W7Ly+UZI8iLAD
5F4OdXRbRze7FYvxtjslkbtEHXUHB5Mtg4WV6d2aw64XGIVQ1YnU3wuwhkBMAFXM
53jdzsueQEbjRI/OO5dYXGztYx2nsikBYi5elWq4vwlSdUoz/tDlQMFIeaNzoAn5
LkbH7U6oeO6+oAkHchR/
=qjMk
-----END PGP SIGNATURE-----

--Apple-Mail=_DF189946-87AD-4F5E-9AA1-6ACC9EBD2A68--
