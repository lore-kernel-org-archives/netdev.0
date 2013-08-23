From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH net-next 06/10] net: airo: inherit addr_assign_type along
 with dev_addr
Date: Fri, 23 Aug 2013 10:53:06 -0400
Message-ID: <20130823145306.GC15114@tuxdriver.com>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
 <1377250513-3662-7-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377250513-3662-7-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 23, 2013 at 11:35:09AM +0200, Bj=F8rn Mork wrote:
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
>  drivers/net/wireless/airo.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.=
c
> index d0adbaf..7fe1964 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -2693,7 +2693,7 @@ static struct net_device *init_wifidev(struct a=
iro_info *ai,
>  	dev->base_addr =3D ethdev->base_addr;
>  	dev->wireless_data =3D ethdev->wireless_data;
>  	SET_NETDEV_DEV(dev, ethdev->dev.parent);
> -	memcpy(dev->dev_addr, ethdev->dev_addr, dev->addr_len);
> +	eth_hw_addr_inherit(dev, ethdev);
>  	err =3D register_netdev(dev);
>  	if (err<0) {
>  		free_netdev(dev);
> --=20
> 1.7.10.4

Acked-by: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
