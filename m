From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH 24/30] sis900: remove unnecessary break after return
Date: Mon, 21 Jul 2014 08:26:10 +0200
Message-ID: <53CCB282.7070901@brownhat.org>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be> <1405866475-24754-5-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, joe@perches.com, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.infomaniak.ch ([84.16.68.92]:40465 "EHLO
	smtp4.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbaGUGcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 02:32:03 -0400
In-Reply-To: <1405866475-24754-5-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 20/07/2014 16:27, Fabian Frederick ha scritto:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Daniele Venzano <venza@brownhat.org>

> ---
>  drivers/net/ethernet/sis/sis900.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
> index 6072f09..7bea17c 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -2258,7 +2258,6 @@ static int sis900_set_config(struct net_device *dev, struct ifmap *map)
>  		case IF_PORT_100BASEFX: /* 100BaseFx */
>                  	/* These Modes are not supported (are they?)*/
>  			return -EOPNOTSUPP;
> -			break;
>  
>  		default:
>  			return -EINVAL;
> 


-- 
Daniele Venzano
http://www.brownhat.org
