From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH] net: Reserve skb headroom and set skb->dev even
 if using __alloc_skb
Date: Wed, 13 May 2015 20:43:20 -0500
Message-ID: <20150514014320.GA20006@saruman.tx.rr.com>
References: <20150513182738.GA28201@saruman.tx.rr.com>
 <20150513203413.8252.98057.stgit@ahduyck-vm-fedora22>
 <7h8ucs6tzc.fsf@deeprootsystems.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	<linux-kernel@vger.kernel.org>, <balbi@ti.com>,
	<davem@davemloft.net>, <tony@atomide.com>,
	<netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Kevin Hilman <khilman@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7h8ucs6tzc.fsf@deeprootsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 13, 2015 at 02:35:51PM -0700, Kevin Hilman wrote:
> Alexander Duyck <alexander.h.duyck@redhat.com> writes:
>=20
> > When I had inlined __alloc_rx_skb into __netdev_alloc_skb and
> > __napi_alloc_skb I had overlooked the fact that there was a return in t=
he
> > __alloc_rx_skb.  As a result we weren't reserving headroom or setting t=
he
> > skb->dev in certain cases.  This change corrects that by adding a coupl=
e of
> > jump labels to jump to depending on __alloc_skb either succeeding or fa=
iling.
> >
> > Fixes: 9451980a6646 ("net: Use cached copy of pfmemalloc to avoid acces=
sing page")
> > Reported-by: Felipe Balbi <balbi@ti.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>=20
> Tested this on top of next-20150513 on an ARM/OMAP
> (am335x-boneblack.dts) an it fixes the boot problem for me.
>=20
> Tested-by: Kevin Hilman <khilman@linaro.org>

Yeah, I know it's too late, but I also tested on my AM437x SK.

Tested-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVU/24AAoJEIaOsuA1yqREyq8P/3WlkGcKeWdhNASUDUkXm0vL
A2WWN5/aiG8V4UXa4oTEcSfE0M3Ugt8Pxn4bjKEfMYvi6b85ik2fSB+i2UBEj3+i
6BmSveeESRehncfLCymelrE8FCnBdX5hHGNEpBWsfDq5M6Si6il1AUyiEldtVA9y
+GmeTPOe4UpIfqdtclg0dDoNjJZkbeI/uGUt9gYMsddpBAo6Y49qV2KCy5YO+SM0
OMEIMYrdEdk2aVuY8grmvmvUYCbxur1OYvlUYD5oMf9/SuaB0fXnnH6kUYYkEnP1
lmP2mqNsOD5fwLW6/94/gbS34bSwkKjm1QKBMxerNpTLsVqUq5LOf+bB9DhfioFg
347wUgGiuvB5cejVJuI9WdeM29DzgPH/8sGQweKpSAG+A8Cdbm4OXLU+eSU6XX+T
LQ5z3RtkAHgDX87EVLj76Da+IVraqZWY0gg4jsKuBSOqOTRWCF83LZV3Dvp9P7//
qQ0Ki/GmwQzrwvEafFDIBZUhskY0RJHZdcFyTCD0mRXKw7uRVS9WkfejJy/UitlQ
gf6afnMt0m9IKBXscJXye5DYZqeuptRbF/wfBQt8cDLiUVVhho5UgmASVqfQc4cw
ZJRWrTr7GXjGdUMf6ogyb2OgroGVQa5cGaYgCChX+9UxXPHGCvKjKA96Gf6PYmup
uG+f3rWXoczo8j4bqhMr
=v4wa
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
