From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] WAN: Fix confusing insmod error code for C101 too.
Date: Fri, 25 Apr 2008 02:02:04 -0400
Message-ID: <481173DC.6010907@garzik.org>
References: <m3myno5u5b.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58472 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756087AbYDYGCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:02:06 -0400
In-Reply-To: <m3myno5u5b.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> WAN: Fix confusing insmod error code for C101 too.
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
> index c4c8eab..c2cc42f 100644
> --- a/drivers/net/wan/c101.c
> +++ b/drivers/net/wan/c101.c
> @@ -402,7 +402,7 @@ static int __init c101_init(void)
>  #ifdef MODULE
>  		printk(KERN_INFO "c101: no card initialized\n");
>  #endif
> -		return -ENOSYS;	/* no parameters specified, abort */
> +		return -EINVAL;	/* no parameters specified, abort */
>  	}
> =20
>  	printk(KERN_INFO "%s\n", version);
> @@ -420,11 +420,11 @@ static int __init c101_init(void)
>  			c101_run(irq, ram);
> =20
>  		if (*hw =3D=3D '\x0')
> -			return first_card ? 0 : -ENOSYS;
> +			return first_card ? 0 : -EINVAL;
>  	}while(*hw++ =3D=3D ':');
> =20
>  	printk(KERN_ERR "c101: invalid hardware parameters\n");
> -	return first_card ? 0 : -ENOSYS;
> +	return first_card ? 0 : -EINVAL;
>  }
> =20

applied


