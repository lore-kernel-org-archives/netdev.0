From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] 6lowpan: use netdev_alloc_skb instead
 dev_alloc_skb
Date: Sat, 26 Oct 2013 01:42:14 -0400 (EDT)
Message-ID: <20131026.014214.1636999222808937267.davem@davemloft.net>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
	<1382647904-11311-4-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3JZFmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 01:42:18 -0400
In-Reply-To: <1382647904-11311-4-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Thu, 24 Oct 2013 22:51:42 +0200

> @@ -1127,12 +1127,12 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
>  
>  	lowpan_raw_dump_inline(__func__, "6lowpan fragment header", head, hlen);
>  
> -	frag = dev_alloc_skb(hlen + mlen + plen + IEEE802154_MFR_SIZE);
> +	frag = netdev_alloc_skb(skb->dev, hlen + mlen +
> +			plen + IEEE802154_MFR_SIZE);

Please indent this properly.

It should be something like:

	frag = netdev_alloc_skb(skb->dev, hlen + mlen +
					  plen + IEEE802154_MFR_SIZE);
