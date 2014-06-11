From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: add __pskb_copy_fclone and
 pskb_copy_for_clone
Date: Wed, 11 Jun 2014 15:14:26 -0700 (PDT)
Message-ID: <20140611.151426.1918105360214405187.davem@davemloft.net>
References: <1402522887-10600-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, marcel@holtmann.org, gustavo@padovan.org,
	johan.hedberg@gmail.com, arvid.brodin@alten.se, kaber@trash.net,
	pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, andrew.hendry@gmail.com,
	edumazet@google.com
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaFKWO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:14:28 -0400
In-Reply-To: <1402522887-10600-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Thu, 12 Jun 2014 00:41:27 +0300

> @@ -2235,9 +2241,17 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
>  static inline struct sk_buff *pskb_copy(struct sk_buff *skb,
>  					gfp_t gfp_mask)
>  {
> -	return __pskb_copy(skb, skb_headroom(skb), gfp_mask);
> +	return __pskb_copy_fclone(skb, skb_headroom(skb), gfp_mask, false);
>  }

This hunk is unnecessary, the whole point of keeping __pskb_copy()'s signature
the same is to avoid these kinds of edits.

Please get rid of this hunk and I'll apply this, thank you!
