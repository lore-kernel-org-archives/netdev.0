From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] [PATCH] batman-adv: Omit unnecessary memset of netdev private data
Date: Fri, 17 Mar 2017 12:54:57 +0100
Message-ID: <5753967.hXycxaDlX0@bentobox>
References: <20170317110859.9273-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2484949.QoaI9YlGiM"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Tobias Klauser <tklauser@distanz.ch>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:33752 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750898AbdCQLzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 07:55:05 -0400
In-Reply-To: <20170317110859.9273-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2484949.QoaI9YlGiM
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

On Freitag, 17. M=E4rz 2017 12:08:59 CET Tobias Klauser wrote:
> The memory for netdev_priv is allocated using kzalloc in alloc_netdev
> (or alloc_netdev_mq respectively) so there is no need to set it to 0
> again.
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  net/batman-adv/soft-interface.c | 4 ----
>  1 file changed, 4 deletions(-)

Thanks, applied in 9210dca17a0acc2d01928893a61647153d578e33 [1].

Kind regards,
	Sven

[1] https://git.open-mesh.org/batman-adv.git/commit/9210dca17a0acc2d0192889=
3a61647153d578e33
--nextPart2484949.QoaI9YlGiM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljLzpEACgkQXYcKB8Em
e0YebA//cCRmJQDtnWrfW5Mvj+iJLkRywRWCClB478G45fW+xRpi/m4rr7VBzeSW
2OqxuNJQLIYPzWSxgigRIHGbXotS3KMeB1tgicOCP9lXcPbrnxFrHB9IddkLlj2j
nYZkZ9Kej/+9hW2teCbcSUd5ErAj5BUo5NoTdcl4zVyhlWJSi4tZCnvAHN64Luq6
DLCD6JpF3qS1S4j3U8WQl/6dC02d7Bu54ouyxolegdcwmXzr/qsDodytNEtyYi40
UU2IyfBeYfgcEqXZBBFKuxb98giecJk1XezWEQV/bpMpmCBkFz2UypOmmbm+a9Ra
WICrkN+MBGqL68qa0rZT5veT5dXr+kqyfjZrq/LVpJQwUOZ+nqUjoXTOocEgacbR
BY7EoF9Ca7RT/ozxS/+i/3IHKJCrG2DtrzOxnZzEthO7/69SkiMd1iGYiSFW2tsw
Ink+27dWvGC9ZnkmYLyvCpJ5PFYfuwogdCLJoxEAJbjY382nBeug2vGto509l3fW
fRc6xoYVdtOhOfLoHEznwHbbVdj7qdJaDTcuQLYaWTlD/BdC+JoKraCJe7D5wI1z
42N2ehc5mqmAvg+TLPG8PMRKrzE71LcQESszxxrVu7r7jaSDTv89+jARDozEJeDq
aqOW8xdLk89zUMYIzWH3WPkPF429o3i/WILWMa0JBBKQpRDgAHg=
=MY+Y
-----END PGP SIGNATURE-----

--nextPart2484949.QoaI9YlGiM--
