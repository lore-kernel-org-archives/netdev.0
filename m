From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH 10/38] don't wrap mlx4_remove_one in __devexit_p
Date: Wed, 25 Nov 2009 10:19:01 +0100
Message-ID: <4B0CF685.6060208@lastsummer.de>
References: <1259096853-18909-1-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-2-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-3-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-4-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-5-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-6-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-7-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-8-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-9-git-send-email-u.kleine-koenig@pengutronix.de> <1259096853-18909-10-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.co.il>, netdev@vger.kernel.org
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758555AbZKYJvx@vger.kernel.org>
In-Reply-To: <1259096853-18909-10-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uwe Kleine-K=C3=B6nig wrote:
> diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
> index 291a505..a581860 100644
> --- a/drivers/net/mlx4/main.c
> +++ b/drivers/net/mlx4/main.c
> @@ -1293,7 +1293,7 @@ static struct pci_driver mlx4_driver =3D {
>  	.name		=3D DRV_NAME,
>  	.id_table	=3D mlx4_pci_table,
>  	.probe		=3D mlx4_init_one,
> -	.remove		=3D __devexit_p(mlx4_remove_one)
> +	.remove		=3D mlx4_remove_one
>  =20
You may want to add the trailing comma while you're at it...

>  };
> =20
>  static int __init mlx4_verify_params(void)
>  =20

f
