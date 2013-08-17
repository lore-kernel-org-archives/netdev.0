From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [B.A.T.M.A.N.] pull request net: 2013-08-17b
Date: Sat, 17 Aug 2013 19:31:15 +0200
Message-ID: <20130817173115.GB849@ritirata.org>
References: <1376737486-1863-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qndya+I13rh6QJ0p"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:21356 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab3HQRdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 13:33:53 -0400
Content-Disposition: inline
In-Reply-To: <1376737486-1863-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qndya+I13rh6QJ0p
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 17, 2013 at 01:04:44PM +0200, Antonio Quartulli wrote:
> Hello David,
>=20
> here is the correct pull request for net/linux-3.11.
>=20
> As described earlier this patchset contains a change which properly ends a
> seq_read cycle and another change that takes care of aborting TX operatio=
ns if
> the skb preparation should faile.

Hi David,

sorry for the noise but after analysing the code once more we realised that
skb_abort_seq_read() is not needed anymore for >=3Dlinux-3.11.

Therefore one of the patches in this pull request is not needed.

I will send a third pull request with the correct patch only.


Thanks,
	Antonio

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--qndya+I13rh6QJ0p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSD7NjAAoJEADl0hg6qKeOt8QP/j0jV9xmjDoS9zwCUYXjX7mL
WkAFZ6+/Zo2rEvLMrzxoUR8Z9m8vIh2ufErJqOr5tVzTR1egLLfXXlVUwhiS3waN
So/lddD6aqrcyR5jEf98G1e8Kfqco9KDxR/sNJf6HGRV5wEdQGVxsTgCG9wRdqeZ
Y0lPVGwPEXXfo+zk/6nO/6DZ/Mo2odWK2AFvm/uVyTsttSHyNmQ4DUyFTuYUjKWP
jDer6aXt1GiQ2isL3HzC6eS3BbhDDYsXTsPpNeKEwKf4M9AO0aQcb7UUbjEqpkMS
f1vlOCQosUir4Q0acFcYVXEYQQt6CkC2xTJNZsGbGQcv9eX7NaYWp5oyw41txi7i
l5hXlpX3QnrzvFwgwoSALmP/IyK3XJ6XcUeRWja6hw4N2rMMDr+UyfPOM2JoQnyw
bJCL7qFh4EZWLfq6oTTjJf4I5GWVAiVU83VLZbJSS6NEydydI70z+v9of1qj9u19
9RFIhieHc7/PLKSU1aFLQ3fbhjNZ0PiszZnhm66ogYQ760sWVqnq4n/kDSSDd77A
7vukX8Dk+6zooGwht9pKrRgWzHDP/n39efHqAyKdPMkL6hdB9TelrEpPOuwVjYs3
JyVMpxchS2TZsIYZR9HnGzPrVx0dVXoxXzCEU22kAHQNZu4AYYf5hqAWR2XVW04J
wOyVtK+jHdF0C1gid5uO
=7zLR
-----END PGP SIGNATURE-----

--qndya+I13rh6QJ0p--
