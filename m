From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Tue, 24 Mar 2015 00:38:28 +1100
Message-ID: <20150324003828.0eac53d9@canb.auug.org.au>
References: <20150323140841.0b807b95@canb.auug.org.au>
	<20150323124723.GA6740@salvia>
	<1427115331.16851.11.camel@perches.com>
	<20150323130638.GA6857@salvia>
	<1427117031.16851.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/mKb.jgrBtddzCuDJlUZXgIe"; protocol="application/pgp-signature"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427117031.16851.16.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/mKb.jgrBtddzCuDJlUZXgIe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Joe,

On Mon, 23 Mar 2015 06:23:51 -0700 Joe Perches <joe@perches.com> wrote:
>
> Use the #defines where appropriate.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> > > Perhaps all the .level =3D 4 uses should be LOGLEVEL_WARNING
> > > and .level =3D 5 should be LOGLEVEL_NOTICE
> >=20
> > Yes, we can push a follow up patch to net-next changing all these
> > spots in the netfilter tree. Would you send a patch for this?
>=20
> There are indirect includes of kern_levels.h but there are a
> lot of indirect includes of kernel.h in netfilter

I am not sure what you are getting at here.  kernel.h does not include
kern_levels.h (but printk.h does).  I, for one, am always happier when
necessary include files are explicitly included.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/mKb.jgrBtddzCuDJlUZXgIe
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEBdaAAoJEMDTa8Ir7ZwVVzwP/jAgiTOtOG8ARUIEOUZpNz6/
e4SOAidxfm89SCkOE/8C6k0clIHLszeuX38EroTOu8PSoRj9CjsCMr9Kbg0tyNGB
CQRHpK7bKD2ASaW9f8S1sy7XYO4kghmzv+daRI7lQPYJXJGYUNRAqV6KXxq4rNp/
QfppjtnJZUCk8PrjcXuDxkXN863AuqeWUVpdzBTSujMDjoVh/K212sQu9lo9py7c
/jefUhHJNYi/zpysKTdKs8kN+ur4c33MOQNNp4TpuwRHHMMk/lrS4VzZRQVYH81L
HvHUk8iSOSLEcVuT12VoW+1Ua8lecFZ/gHixSm5KUYvQNZBSU4+Bm+b1GQKeBD5M
JVhENJn25eRL0wyXMAyWV3fDDWBh/bXeROX+XVFM5Orc/0ZllN9u05/gxN1KIDkw
6xKMQVktYgp3kXaX6eyuWe4oeF6+AYXrgyW9AkryKWUUpgqB2eiFEVGATQCZP5s5
eIBe2RNzD4Yw8ouC1/hjvv70jWHLEf4Z52LO2ijrTkD08MEisu1r8OeSMr/ORPU4
jP9rH7yynBW78WAu1OZUL/lK9eWD+2CQgcYAxPCDx90hsg5+ZKtMuMHI/QlHoLCm
34EOHvguLUBG9iG+3SyLg77xc20zr6TT0n/3GBREv2rfmLF8akUT4oXFA36KeC9q
L+GhJSueGN4jCv1IuE2O
=BEE/
-----END PGP SIGNATURE-----

--Sig_/mKb.jgrBtddzCuDJlUZXgIe--
