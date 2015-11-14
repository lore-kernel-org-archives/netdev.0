From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Sat, 14 Nov 2015 17:39:25 +0000
Message-ID: <1447522765.17039.7.camel@decadent.org.uk>
References: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IzI/XSVgS80NE7actQy9"
Cc: herbert@gondor.apana.org.au, stable@vger.kernel.org,
	hannes@stressinduktion.org
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-IzI/XSVgS80NE7actQy9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-10-15 at 14:25 +0200, Sabrina Dubroca wrote:
> Without this length argument, we can read past the end of the iovec
> in
> memcpy_toiovec because we have no way of knowing the total length of
> the
> iovec's buffers.
>=20
> This is needed for stable kernels where 89c22d8c3b27 ("net: Fix skb
> csum races when peeking") has been backported but that don't have the
> ioviter conversion, which is almost all the stable trees <=3D 3.18.
>=20
> This also fixes a kernel crash for NFS servers when the client uses
> =C2=A0-onfsvers=3D3,proto=3Dudp to mount the export.
>=20
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Note: this is based on 3.14.54, as 3.18 doesn't need the hunk for
> net/rxrpc/ar-recvmsg.c, but all older stable kernels do.
[...]

Queued up for 3.2, thanks.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-IzI/XSVgS80NE7actQy9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVkdxzee/yOyVhhEJAQq8cA//UEawqtE4hCacZKOXnL+LOwlsA592ThaA
jrSY7wXWRch2YAgzr4VKgUo+Wni+cPW0M0aXlUeJrf3K1JG092fcz5qIjUbjRNGT
a4EhQmW4NfVnEmGgmKXSTitmtNOGFKk+35tVXRVenIMkgWg5nWG/SGS2dA95URMQ
zxCZxsQ70hvSSY2UerkwupQfVVFvAqVuBy2HCn8CkhMzDvac+qDYeXOE+7LB5Uq0
OFQXzTY1ceYVnYa4x2Idl1uMwmA5atq97JdfW3I95cpulweWtxmCRTCwc5ynEA5h
7h1S+gJgNieNnV7tYGsb3Kw6vP7IJBxwOujld1RDRL4qREsq1I3rVCoL8TXG3QCO
8v6TtF6+J1mvxXSTBfOZWA2ZDRFfLT9nAk/deDbb3h5siqQqlamY/bEf+nmR8GDQ
m6R1dkUkLTNNXv3yncPPKhUAKD3pWjsbujD15iQVCQkfkPsdO7vtuhaATWqNz2Qk
aOgQz9BAuViTKv3gmbnnW617OcIs+jx21oU1ElxD5Wa/DdrrsD7RaLcJ6JF0WxOD
831EL8qte7zNpo0ePyHTaIeCLcYafKBwJM4ZlNkThMk5sZxHOHpDrlG4S7AGfSkQ
ruXQPI23+xvxGdydPA6Lzs7KZPtupMdxRUR7L/ABmgakVulKIyJtQHz5zsc8oTHK
2myp560rOpg=
=N14W
-----END PGP SIGNATURE-----

--=-IzI/XSVgS80NE7actQy9--
