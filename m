From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] hv_netvsc: add ethtool support for set and get
 of settings
Date: Tue, 01 Mar 2016 15:31:16 +0000
Message-ID: <1456846276.3098.156.camel@decadent.org.uk>
References: <1456442648-13941-1-git-send-email-sixiao@microsoft.com>
	 <20160229.170910.1568620456454101151.davem@davemloft.net>
	 <1456785278.3098.146.camel@decadent.org.uk>
	 <20160229.175040.1966545191136367460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oYLWnctYUz8ysdTHovxr"
Cc: sixiao@microsoft.com, kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160229.175040.1966545191136367460.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oYLWnctYUz8ysdTHovxr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-29 at 17:50 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 29 Feb 2016 22:34:38 +0000
>=20
> > On Mon, 2016-02-29 at 17:09 -0500, David Miller wrote:
> >> From: Simon Xiao <sixiao@microsoft.com>
> >> Date: Thu, 25 Feb 2016 15:24:08 -0800
> >>=C2=A0
> >> > This patch allows the user to set and retrieve speed and duplex of t=
he
> >> > hv_netvsc device via ethtool.
> >> >=C2=A0
> >> > Example:
> >> > $ ethtool eth0
> >> > Settings for eth0:
> >> > ...
> >> >=C2=A0=C2=A0=C2=A0=C2=A0 Speed: Unknown!
> >> >=C2=A0=C2=A0=C2=A0=C2=A0 Duplex: Unknown! (255)
> >> > ...
> >> > $ ethtool -s eth0 speed 1000 duplex full
> >> > $ ethtool eth0
> >> > Settings for eth0:
> >> > ...
> >> >=C2=A0=C2=A0=C2=A0=C2=A0 Speed: 1000Mb/s
> >> >=C2=A0=C2=A0=C2=A0=C2=A0 Duplex: Full
> >> > ...
> >> >=C2=A0
> >> > This is based on patches by Roopa Prabhu and Nikolay Aleksandrov.
> >> >=C2=A0
> >> > Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> >>=C2=A0
> >> Applied, thanks.
> >=C2=A0
> > I missed this due to flu, but now I look at it - I don't see the point.
> > Link speed isn't meaingful for a memory-based transport, so "unknown"
> > is correct. =C2=A0The link is effectively full duplex though.
> >=C2=A0
> > If the issue is that ethtool is a bit shouty about unknowns, let's
> > consider changing that in ethtool, not teaching drivers to lie.
>=20
> The issue is that certain bonding modes do not work properly without
> a speed being reported by a device.

Ah, of course.

> We're doing this for other "virtual" devices already thanks to changes
> that went in last week, so there is precedence.

I know, just wasn't convinced it was a good precedent.

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.
--=-oYLWnctYUz8ysdTHovxr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtW1xOe/yOyVhhEJAQpmtxAAuPOnSYUvIik5b/uFBw513ZCOKbRBe4tF
U+KEL6dkZm8GE3ttRdI3wJXxJBLES2Y5mnW5bAq8BkGwYeWQnzya71z3cxkKN2Wp
ZqLrVmgOdX9iqnspgOYPVDHhTaCHA3LpYvwk/q7E+hMwIj2jxN8hIjMiAthg5F1B
pJ6Nm4Fc5uch2RBGvwMdA9T1rfuCnJR+lMqGwLr6V5eZiA5cwhnOD25D4Vsora+h
Soa1zsC7N7KWtJs4w0uoBuBUpd6oaC/BVizQBrLEBrjblRDoFZ4vfJVA2PMb2gv6
SiHN0QCy97f96cXsi6i6WxU1sLseCPdvkf7ayWBf4LRPE0NX1SwX+84FkpepKOJs
qoCFiuToQJBPsrTCx6DmNLef/8+kPFI0xZNuSvDclEMx6GX7222ZM3O9yyna3Qst
7m9hkRcrvY5Xd6xSIBEfpYdEFP7NwcdAaCEW+HNdpqpmgB0wwpg6AnaDqnQKldGC
hWrofucadi1kE8L2uCfcT/js0rIWYicYZDizx2+8ZEf1OfHtUfNIOAU1izZcn6f1
O/GwUMAhzBeuybAUyxs6LReVgWaeRjGf4K39WzyBHECIPGMnF/PnriRTL3iuLINH
3RTbjO+5HlIQyWI/8WQ81PKpZKDDV/KljJsQwLE2j8MNyRGoR+9Mm9wUwd8WG2NQ
J9m4pOj7I/Q=
=WTMX
-----END PGP SIGNATURE-----

--=-oYLWnctYUz8ysdTHovxr--
