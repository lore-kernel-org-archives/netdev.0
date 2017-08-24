From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] ipv6: sr: add support for encapsulation
 of L2 frames
Date: Thu, 24 Aug 2017 14:15:21 -0700 (PDT)
Message-ID: <20170824.141521.105174223642988977.davem@davemloft.net>
References: <20170823153203.11951-1-david.lebrun@uclouvain.be>
        <20170823153203.11951-3-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753861AbdHXVPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 17:15:22 -0400
In-Reply-To: <20170823153203.11951-3-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Wed, 23 Aug 2017 17:32:00 +0200

> +	case SEG6_IPTUN_MODE_L2ENCAP:
> +		head = sizeof(struct ipv6hdr) + 14;
> +		break;

This 14 is ETH_HLEN.

>  
> +		if (pskb_expand_head(skb, skb->mac_len, 0, GFP_ATOMIC) < 0)
> +			return -ENOMEM;

But you seem to support arbitrary L2 MAC header sizes.

Please sort this out.
