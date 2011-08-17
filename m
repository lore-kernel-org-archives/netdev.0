From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: boot test failure (net tree)
Date: Wed, 17 Aug 2011 10:50:02 +1000
Message-ID: <20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
References: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
	<20110816.171525.639251389938336183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__17_Aug_2011_10_50_02_+1000_bjSpbQJdqfBPVWqv"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110816.171525.639251389938336183.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__17_Aug_2011_10_50_02_+1000_bjSpbQJdqfBPVWqv
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 16 Aug 2011 17:15:25 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 17 Aug 2011 10:01:46 +1000
>=20
> > In particular, CONFIG_TIGON3 newly depends on
> > CONFIG_NET_VENDOR_BROADCOM which will no be selected when doing a
> > "make oldconfig" from a working config.
>=20
> When you type "make oldconfig" with an existing .config it prompts you
> for those vendor guards, giving you ample opportunity to say yes to
> them.

Which is a bit of a pain for automated systems.  Ours does (essentially):

yes '' | make oldconfig

We really don't want to select every new config item that comes along.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__17_Aug_2011_10_50_02_+1000_bjSpbQJdqfBPVWqv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOSxA6AAoJEDMEi1NhKgbs5poIAJX2IEDHnKRjzgCYHQ+OOreD
cLUNWn/D6O0YRT7j7OGd/NEWGpuYFAyDyCRCZohrccUu741Y9RC9J9x3dwrBK5Wv
vNR1eJlSJh/aREV88gC1R5B+aKm2jZR4JmdiZ4tP+sQQme7wgZLn84xbiu8tr2sr
2kNHMDGWIldu1SKdMTqx56OI4W3RrSenEWDjgQeM5dxITNUaur1kBzG9MlJ/KEzT
NAC+K5s8/T4ONhV29LZnbS7QQnhTu3W7uOgSfhaY0x5MOXAieHEsxD8Km0IslYR/
IQlLrLBeBlQnaEbCraceJz5jL7DP7pzLhDZlNknuK40ZTAWYqyOIEoQfleOU+gg=
=LZcD
-----END PGP SIGNATURE-----

--Signature=_Wed__17_Aug_2011_10_50_02_+1000_bjSpbQJdqfBPVWqv--
