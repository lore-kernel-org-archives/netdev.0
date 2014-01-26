From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] 8139cp: remove a won't occurred BUG_ON
Date: Sun, 26 Jan 2014 23:23:43 +0000
Message-ID: <1390778623.2735.69.camel@deadeye.wl.decadent.org.uk>
References: <52E4C862.9050103@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YlhemskRmStuTzvYoBCO"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53970 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753040AbaAZXX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 18:23:56 -0500
In-Reply-To: <52E4C862.9050103@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YlhemskRmStuTzvYoBCO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-01-26 at 16:33 +0800, Wang Weidong wrote:
> when variable i go to the BUG_ON the value is equal to the CP_NUM_STATS,
> so the BUG_ON won't occur, so remove it

We hope that every BUG_ON() does not occur, but that doesn't mean they
should be removed.  This check is meant to catch mistakes when adding
new statistics.

Ben.

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  drivers/net/ethernet/realtek/8139cp.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet=
/realtek/8139cp.c
> index 737c1a8..b70e184 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -1585,7 +1585,6 @@ static void cp_get_ethtool_stats (struct net_device=
 *dev,
>  	tmp_stats[i++] =3D le16_to_cpu(nic_stats->tx_abort);
>  	tmp_stats[i++] =3D le16_to_cpu(nic_stats->tx_underrun);
>  	tmp_stats[i++] =3D cp->cp_stats.rx_frags;
> -	BUG_ON(i !=3D CP_NUM_STATS);
> =20
>  	dma_free_coherent(&cp->pdev->dev, sizeof(*nic_stats), nic_stats, dma);
>  }

--=20
Ben Hutchings
If the facts do not conform to your theory, they must be disposed of.

--=-YlhemskRmStuTzvYoBCO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuWY/+e/yOyVhhEJAQoCRg/9ET2bc/3KbKSuywjX+H5ayrmVhyqh5m5b
V3ItX21SaQmXVS2PK2IiYO4W2858MxiQ8xA4QDTP1a333QyiuVqK+ql6894WrWkS
L+lzNP7p1LX8UWVM/fUKaRpq7CrAn5TbXlywuHmxvbXWSzQkoyf1hnciIoMgM5DY
336B/Iy7hQzfUietfAhjDeRwMls0OHjwt7vFMXZZ27vV8UVt7/Fqazhljoymv3T9
1WOw1plYzmkR1OrcLf7ktHMq+jTKSnzjx5s1tcuzuefDK9A3CZA/eeSj4wh+8mKx
dX3jib41Ui3oGvY3766gCvLgMTetG5tvOQBjhn43fhMwkkUEFJ1D8HPFbNq3d/Of
k0G79KCOhc5Db1EeZz25rvgKRFreG+XksKaHoEFEGRmsR/Lc3K30TTdTu1/V2g2e
lqIg3E+GWJbNBxhIiDQOAkeYJWd0YB8YjlGhu2u10Haqcaheu+n66fkb38G61iZl
V2FhhsV7WCLPjOmF1X9ZPnTBH+gK6QIf2UJrcN/hATywHBikWMjp20QyEstw4Rr3
fkNvcwLNQ1jOszdd/pxJaZ3GISyzQX9TPl5pMKN5pKkZ5z3RqCPNWOJRyZoJmvCO
vUahF1vnq2FddFaL59J1a7g0x8s/JQnTpJNttOhGQaEZSWxVsccm3u+HJgQoMmcQ
m0Jh8JOTHco=
=+OsZ
-----END PGP SIGNATURE-----

--=-YlhemskRmStuTzvYoBCO--
