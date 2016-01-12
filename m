From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 0/3] can: sja1000: support for technologic version
Date: Tue, 12 Jan 2016 08:56:48 +0100
Message-ID: <5694B1C0.2070702@pengutronix.de>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <20160111165807.GA7116@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="qd0fq63gn5xcxB9058qVO509IiqGwR9GG"
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160111165807.GA7116@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qd0fq63gn5xcxB9058qVO509IiqGwR9GG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2016 05:58 PM, Damien Riegel wrote:
> Hi Marc,
>=20
> On Thu, Dec 24, 2015 at 12:42:50PM -0500, Damien Riegel wrote:
>> This patchset introduces support for the technologic version of the
>> SJA1000. Access to IP's registers are proxied through a window,
>> requiring two bus accesses to read or write a register. These accesses=

>> must be protected by a spinlock to prevent race conditions. Currently,=

>> there is no easy way to allocate and initialize this spinlock.
>>
>> SJA1000 already provides a way to allocate private data, but
>> sja1000_platform.c makes no use of it.
>>
>> Patch 1 adds the capability to allocate and initialize private data on=
 a
>> per-compatible basis in sja1000_platform.c.
>>
>> Patch 2 updates device tree documentation to add the technologic
>> version.
>>
>> Patch 3 updates the driver to implement the technologic version
>>
>=20
> Did you have a chance to take a look at this patchset? I would
> appreciate your feedback, especially on the first patch.

Done. 2/3 is ok. For the others see my comments.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qd0fq63gn5xcxB9058qVO509IiqGwR9GG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWlLHAAAoJEP5prqPJtc/HbOYH/jfrArHf4UByYAnjGptfKNGH
L8+7GuFQGbBxWenor0jN53BbfypqHRzReDeyP17BElJnXkmHg6iOL6MXKmR6RSBp
CNOqpAHjrIH0t2VWUgeQvC6LS5ZgUBpfrQBV0hI9e+ZW18qdnWT79awMzOH3bbrk
1/llwHKLkzYNFmmPWsI6dZfEvZmw7AE6LA4+CbRKM3QZYZ9gSklf7JoqmxoJA+pw
6vn2qF+cjMvpC/bDAOTvdxlDdlp6jBBiSoOj12GTgA7v3bBlhzboBHTcBhoWNVny
2GSUJxYG20TM6c56CJSfQftY9uClSB7/0yBEgqZXfstoOQt3ZtWTGWjXJe/zo6U=
=ISa7
-----END PGP SIGNATURE-----

--qd0fq63gn5xcxB9058qVO509IiqGwR9GG--
