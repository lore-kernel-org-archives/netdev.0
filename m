From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 19 Jan 2015 14:30:24 +1100
Message-ID: <20150119143024.5b8a20bc@canb.auug.org.au>
References: <20150119140610.6b41b5ef@canb.auug.org.au>
	<289C7DCC-D2B3-43B6-B661-EE19371D8B17@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/UVDpwO0fqhEO6FPcLuZx=gA"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <289C7DCC-D2B3-43B6-B661-EE19371D8B17@holtmann.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/UVDpwO0fqhEO6FPcLuZx=gA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

On Sun, 18 Jan 2015 19:13:17 -0800 Marcel Holtmann <marcel@holtmann.org> wr=
ote:
>
> > After merging the net-next tree, today's linux-next build (powerpc
> > ppc64_defconfig) failed like this:
> >=20
> > In file included from net/bridge/br.c:22:0:
> > include/net/switchdev.h:73:1: error: expected identifier or '(' before =
'{' token
> > {
> > ^
> > include/net/switchdev.h:71:19: warning: 'call_netdev_switch_notifiers' =
declared 'static' but never defined [-Wunused-function]
> > static inline int call_netdev_switch_notifiers(unsigned long val, struc=
t net_device *dev,
> >                   ^
> >=20
> > Caused by commit 03bf0c281234 ("switchdev: introduce switchdev notifier=
").
> >=20
> > I have used the net-next tree from next-20150116 for today.  I also had
> > to use the bluetooth tree from next-20150116 as it was fast forwarded
> > to be the same as the net-next tree today.
>=20
> it seems Dave forgot to push out his net-next tree, but in theory it shou=
ld contain a fix for it.

Or he did so after I fetched his tree this morning.  Either way, I
assume it will be fixed tomorrow.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/UVDpwO0fqhEO6FPcLuZx=gA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUvHpVAAoJEMDTa8Ir7ZwVoOEQAIDH+0r/KVjGe99kX5a8XPOh
dKp0XMD2F3bTa4OUfDHfdDyDekL/hlClT71CveBq5rzN1/PcrtdK4rmf0P8KnrMm
LXXKdkcgVU8MvZSWhc9sEWt1yKXD8dfoJsAx0BIRXRpvbz8R67FFOuemnbLaHHSU
C+fbm5ZJgu5GGBbfyrcT1ADGUP8ht3G6vE5xxOi7hbyPO0cZwiVnXahS9/QkN7mP
c4Lm0krztc4apFMsAXZmYlR4nQLUNE81UbfyUwhIfeN4dVy3rHFET46djFUF9JoO
S0QOthPmq3gVPQd7SwLjBzT1Wbuz9iArzZvqfd8NHlMjipcAGgN4SGNmm71jntqi
QsWIlrXCrHgLjZkns5p0jM9dSOJ7mo2HtHrmzzdFu86bYzb1IC3tY5+0ANyoGj3t
GzGIAfPIcAyMF9MSmnjIYkQZA46c+WQvcpaAy4RSffQRbjKDKomk7RGynq9qTBJk
GFGc/2LrV5IYcu068IQYDg1eVtXh/aXAXyu/YE0uH1BU2sCjOVCzLvTxUlddCgg0
TonwPKIi5VJtcZDWdkaP1L2zWgP4GwjHe41YLDhFm+iUVYS8oJTB15ANbLi5H12D
8gSTtP40rOkSX0XzrzJWFAulMyyRZwMKjeNQwlIIj7QenglrfDLh01MjtED89kMy
96MFzFcBPCL2Yd9AUwW4
=YVFl
-----END PGP SIGNATURE-----

--Sig_/UVDpwO0fqhEO6FPcLuZx=gA--
