From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sc92031: remove bogus unlikely()
Date: Fri, 30 May 2008 22:12:52 -0400
Message-ID: <4840B424.8060308@pobox.com>
References: <483F513C.5010303@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37104 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbYEaCMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:12:54 -0400
In-Reply-To: <483F513C.5010303@cesarb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cesar Eduardo Barros wrote:
> Commit 5a0a92e67b5009a71e011658da04fb92dad8961f mentions len < ETH_ZLEN
> is true for ARP packets. This obviously is not unlikely.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> ---
>  drivers/net/sc92031.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
> index b4b6380..61955f8 100644
> --- a/drivers/net/sc92031.c
> +++ b/drivers/net/sc92031.c
> @@ -972,7 +972,7 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
>  
>  	len = skb->len;
> -	if (unlikely(len < ETH_ZLEN)) {
> +	if (len < ETH_ZLEN) {
>  		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,

applied


