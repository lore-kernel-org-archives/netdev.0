From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/4] b44: add wol and setup for later 4401
Date: Thu, 25 May 2006 00:06:58 +0200
Message-ID: <20060524220658.GA2863@electric-eye.fr.zoreil.com>
References: <1148481644.2976.51.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:7588 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964774AbWEXWIX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 18:08:23 -0400
To: Gary Zambrano <zambrano@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1148481644.2976.51.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gary Zambrano <zambrano@broadcom.com> :
> 
> This patch adds set and get functions and support for the later 4401 revs.
> 
> Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> 
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 7b3dfc4..e42e0aa 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
[...]
> @@ -1467,6 +1510,11 @@ static int b44_close(struct net_device *
> 
>  	netif_poll_enable(dev);
> 
> +	if (bp->flags & B44_FLAG_WOL_ENABLE){
> +		b44_init_hw(bp);
> +		b44_setup_wol(bp);
> +	}
> +
>  	b44_free_consistent(bp);
> 
>  	return 0;

Should b44_setup_wol() not be used in b44_suspend() as well ?

(nit: s/){/) {/)

-- 
Ueimor
