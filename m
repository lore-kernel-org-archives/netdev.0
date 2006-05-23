From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: endian fixes
Date: Tue, 23 May 2006 14:30:45 -0700
Message-ID: <44737F05.40308@intel.com>
References: <20060515225432.GG10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:8872 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S932121AbWEWVbC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 17:31:02 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060515225432.GG10143@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ack, please apply and add my acked-by/signed-off-by.

Cheers,

Auke


---
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>


Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- 1/drivers/net/e1000/e1000_main.c
> +++ 1/drivers/net/e1000/e1000_main.c
> @@ -2451,7 +2451,7 @@ e1000_tso(struct e1000_adapter *adapter,
>  
>  		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
>  		mss = skb_shinfo(skb)->tso_size;
> -		if (skb->protocol == ntohs(ETH_P_IP)) {
> +		if (skb->protocol == htons(ETH_P_IP)) {
>  			skb->nh.iph->tot_len = 0;
>  			skb->nh.iph->check = 0;
>  			skb->h.th->check =
> @@ -2930,7 +2930,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  	/* Old method was to assume IPv4 packet by default if TSO was enabled.
>  	 * 82571 hardware supports TSO capabilities for IPv6 as well...
>  	 * no longer assume, we must. */
> -	if (likely(skb->protocol == ntohs(ETH_P_IP)))
> +	if (likely(skb->protocol == htons(ETH_P_IP)))
>  		tx_flags |= E1000_TX_FLAGS_IPV4;
>  
>  	e1000_tx_queue(adapter, tx_ring, tx_flags,
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

