From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 02/08] ipg: use NULL, not zero, for pointers
Date: Fri, 27 Jun 2008 01:33:19 -0400
Message-ID: <48647B9F.1070604@garzik.org>
References: <Pine.LNX.4.64.0806231434300.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	Bircoph@list.ru, shemminger@vyatta.com, netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56718 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012AbYF0Fdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:33:31 -0400
In-Reply-To: <Pine.LNX.4.64.0806231434300.23716@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka J Enberg wrote:
> From: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Fixes a sparse warning in a code block that's hidden under JUMBO_FRAME #ifdef.
> 
> Tested-by: Andrew Savchenko <Bircoph@list.ru>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  drivers/net/ipg.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/drivers/net/ipg.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/ipg.c
> +++ linux-2.6/drivers/net/ipg.c
> @@ -1808,7 +1808,7 @@ static int ipg_nic_open(struct net_devic
>  	/* initialize JUMBO Frame control variable */
>  	sp->jumbo.found_start = 0;
>  	sp->jumbo.current_size = 0;
> -	sp->jumbo.skb = 0;
> +	sp->jumbo.skb = NULL;
>  	dev->mtu = IPG_TXFRAG_SIZE;
>  #endif

applied 1-2 to 2.6.26


