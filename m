From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: (unknown)
Date: Wed, 27 Apr 2016 09:38:25 +0300
Message-ID: <20160427063825.GN7974@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BjavXC7V3ilNTWHC"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	FaisalLatif-2ukJVAZIZ/Y@public.gmane.org
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--BjavXC7V3ilNTWHC
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

<faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Bcc:=20
Subject: Re: [PATCH net] RDMA/nes: don't leak skb if carrier down
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
In-Reply-To: <1461529139-28582-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>

On Sun, Apr 24, 2016 at 10:18:59PM +0200, Florian Westphal wrote:
> Alternatively one could free the skb, OTOH I don't think this test is
> useful so just remove it.
>=20
> Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>

I don't know why did you decide to send it to netdev and not to relevant
maintainers, but the relevant mailing list is linux-rdma and Faisal
needs to Review/Acknowledge it.

=E2=9E=9C  linux-rdma git:(master) ./scripts/get_maintainer.pl -f
drivers/infiniband/hw/nes/nes_nic.c
Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (supporter:NETEFFECT IWARP RNIC
DRIVER (IW_NES))
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (supporter:INFINIBAND SUBSYSTEM)
Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (supporter:INFINIBAND SUBSYSTEM)
Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (supporter:INFINIBAND
SUBSYSTEM)
linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETEFFECT IWARP RNIC DRIVER
(IW_NES))
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)


> ---
>  Noticed this while working on the TX_LOCKED removal.
>=20
> diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/=
nes/nes_nic.c
> index 3ea9e05..9291453 100644
> --- a/drivers/infiniband/hw/nes/nes_nic.c
> +++ b/drivers/infiniband/hw/nes/nes_nic.c
> @@ -500,9 +500,6 @@ static int nes_netdev_start_xmit(struct sk_buff *skb,=
 struct net_device *netdev)
>  	 *		skb_shinfo(skb)->nr_frags, skb_is_gso(skb));
>  	 */
> =20
> -	if (!netif_carrier_ok(netdev))
> -		return NETDEV_TX_OK;
> -
>  	if (netif_queue_stopped(netdev))
>  		return NETDEV_TX_BUSY;
> =20
> --=20
> 2.7.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--BjavXC7V3ilNTWHC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXIF5hAAoJEORje4g2clinPQoP/05Bkmp/1ypwB69FlXDnXEio
hDY65BdlFOtCN9dIU+ZmuLGiz9sdWCouBjhjfIMCAlCJgkEQBFRW3OJSRxrm2vSn
u84Umsy5G4tx00oEqYSEgVnsAJBHepZC2dOgKkk+b63maYiGd7ensijIZUkR8Xjl
8+uA9cUAJZZzP7Ey3CSh9ZtkbGoaMbQIXqAGu2XCekctDf3cjEXXUcwAUs/V7PEa
FOUtOeS14T0tZ4SCuNQdi3UemIHzvl355sTup+t3gKdgu1ynnPvflKGJFApY+MRN
9u5VAmrg51W4vegfn4lnCA7NV+8IInsYrYyO5t2ScKfkklhDOL+zzqoHpCJJvtxw
70QFOJP3QGp93WKbypuQ83wI5lzUowV2UPM48QSRdM8DwI5IM6yJHZ2hNvmkW8pO
TrrFD1JCpEOeqyX/Tzuof1e34NXN8Dww/YfRfbA2Ey2q65rYMOhmFbNzx598ld/H
v+MvU0UTQNu7X15egMhm0LrGVSWO3+lURBSGQM+b6Gep+yF1eTgk/60qdV0yonF3
yxiTX7VH5lf4geErH4gDD0NMbW2MEHyizz5oEA6kbda5lbbMkPlZQTYkWYFNmNKC
9RvnfO1Vc9UPvzD3FiLNXeBn18QSjV/MrLeCNfKcw5MnHoX0b7fa9WUen1gaVE+E
0GpiSnUajxsWM2/Jsv6y
=Y5bJ
-----END PGP SIGNATURE-----

--BjavXC7V3ilNTWHC--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
