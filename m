From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V5 1/2] can: m_can: fix not set can_dlc for remote frame
Date: Tue, 18 Nov 2014 21:40:40 +0100
Message-ID: <546BAEC8.6010605@pengutronix.de>
References: <1416308455-29134-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="gTtDdSfKgM6jhg6nLe49FMqqvV7MxuNK7"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416308455-29134-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gTtDdSfKgM6jhg6nLe49FMqqvV7MxuNK7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/18/2014 12:00 PM, Dong Aisheng wrote:
> The original code missed to set the cf->can_dlc in the RTR case, so add=
 it.

Applied both patches. Let's see what David says to the CAN FD support.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--gTtDdSfKgM6jhg6nLe49FMqqvV7MxuNK7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUa67IAAoJECte4hHFiupUly8P/3mQ5Pq1ISn1rGRftbkVo+jN
7deQVRpKVaWzhNi/9hX8su5wh7oYOULWtYQqnQwMahoLCPbBDvkfLnUtxIBOSPbZ
qiDMyXK3GM8sHc2PHJkEvfPuIAWOOoP4MVetuFhVlDLEsWd1DulLlpAlVu5NBtMJ
HBPGXetXSj8lIYCWXh40RtKpk2AUllyL2sy91uUl521pPRuTojUviExFn8PM4Jnb
5yjtyf6ntx68tu8mkbiaYHOUkMSlFAe77J8zE0HM7qBUdRj7v2LVW+uRx24ssMHS
S13GIPD8b5WBeHwLexQgq3g9fytk4K7oHPC5uxvjJmmb346fBJ6uUigWjKWsMJ+U
1tjcoUWLozDWdexPvf9eukuLnKRclFC4CFYWnzzccFha2CtQEmwOFWwlJ866LeqX
j9wQe2NlFFqK9tBMQq0k+7Bn5UlGBFdjcO261GVAwqw7QJSg8eVfdvMvGiw2HDBf
IFtC1YHyWJT3nIMVy8s/Ktpp9q1/k+mg72lsw+B6+gltBZI0NFa/9LqygFzu8otr
pFCXPa1cBpZLDibqVM7m1ZcKaRqR5Ct/ufVpczoMeNN5OFfmTaX2cVddIM/RGzKg
Z+IyTjBsfQdSNDv5WmJMlMC0m5Ncfiji0IkDw6YOuuZ6FPpmSua+vUiD7fEZUVZn
+4KyV5CqfktqT2mcrD2/
=io+R
-----END PGP SIGNATURE-----

--gTtDdSfKgM6jhg6nLe49FMqqvV7MxuNK7--
