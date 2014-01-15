From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net: Add skb_get_hash_noeval
Date: Tue, 14 Jan 2014 16:20:06 -0800
Message-ID: <1389745206.31367.289.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401141556350.25158@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:55229 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaAOAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:20:11 -0500
Received: by mail-yk0-f173.google.com with SMTP id 20so153939yks.4
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:20:08 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401141556350.25158@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 16:01 -0800, Tom Herbert wrote:
> Function to just return skb->rxhash without checking to see if it needs
> to be recomputed.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/skbuff.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index d97f2d0..bbdc847 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -771,6 +771,11 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
>  	return skb->rxhash;
>  }
>  
> +static inline __u32 skb_get_hash_noeval(struct sk_buff *skb)

const struct sk_buff *skb

> +{
> +	return skb->rxhash;
> +}
> +
>  static inline void skb_clear_hash(struct sk_buff *skb)
>  {
>  	skb->rxhash = 0;
