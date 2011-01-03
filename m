From: Ben Hutchings <benh@debian.org>
Subject: Re: [net-next-2.6 02/08] r8169: identify different registers.
Date: Mon, 03 Jan 2011 02:52:11 +0000
Message-ID: <1294023131.3167.138.camel@localhost>
References: <20110102233617.GC5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-SfPedYp8w4Nazb6wZcJ9"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32911 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753261Ab1ACCwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 21:52:18 -0500
In-Reply-To: <20110102233617.GC5780@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SfPedYp8w4Nazb6wZcJ9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-01-03 at 00:36 +0100, Francois Romieu wrote:
> Documentation (sort of).
>=20
> The location are the same, the values are the same but it is
> just accidental. Note that the 810x could cope with a smaller
> value as it does not support jumbo frames.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |   22 ++++++++++++++--------
>  1 files changed, 14 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 3124462..8aa92ad 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...]
> @@ -3036,7 +3042,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioad=
dr, struct pci_dev *pdev)
>  {
>  	rtl_hw_start_8168bb(ioaddr, pdev);
> =20
> -	RTL_W8(EarlyTxThres, EarlyTxThld);
> +	RTL_W8(MaxTxPacketSize, 0x3f);
[...]

Shouldn't the value here be written as TxPacketMax?

Ben.

--=20
Ben Hutchings, Debian Developer and kernel team member


--=-SfPedYp8w4Nazb6wZcJ9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATSE5zOe/yOyVhhEJAQKiiBAA1oC1AmUfmEDPOLM8iu5vrJwQlcwvqDjw
YR/n2WgMRSx1cG1y4336PwbEfSLXx8E5GBIFrgDeJxkoZrglK4upeX8PvNaFt1tg
56EqUBeSUZp0K5wUw3MWnpiFAx8twuQc9wXBlfLE7XRYA4LemnBhtS+irdHXM6Hv
3jxkhkclRNBbQEJGzwbM4EadpDC+10VRpjpr/z1IvR28JC91SjjBrjQyng5Qpy/2
YKEUqGMEDbfr44wXNIfM9I0Kt2e9/CR5MKAWubPUNjBm6i3lgkeMRnK6elksVFY0
ECiez7IcgDO2iowKYxd1uQaGDduAIG099JYCkemBV7zgNJuIGDfJdLBt0x0xbTiK
tLuOnddaKfSWB/6AQUmO/1uhuoOqK3qm3GE7Ag+2JiOHp0gmOXv6B6AaDm6bAcmd
qs4v3hOA4iQX4F3B/uq8TcQ2Lk5Qfzg+c4TsAi7LvhLC7Q3ReW1iGakTBVC4Ebmv
/NIJcylaXzAAEygoxlVOah20STkG7Yvt5ot3/uOeu1fM23iocfU/wy3ebbRKuzwO
+y/JTkHlEQ5fn87Oq/LMjoLys41xzGa1tvx96X+cmi3LRlpPwWRCJ5jKspUPwFV4
dpv3UhjaZweVEZI8qTRfEVlOXUj4CjbPrRK8MAR9hGdURlLN598Vzzy0UYDpu+iX
wshbQS8985Q=
=OEzS
-----END PGP SIGNATURE-----

--=-SfPedYp8w4Nazb6wZcJ9--
