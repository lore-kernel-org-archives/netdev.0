From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macvlan: Send frames to AF_PACKET sockets attached
 to lowerdev
Date: Wed, 27 Apr 2011 23:09:51 -0700 (PDT)
Message-ID: <20110427.230951.260093496.davem@davemloft.net>
References: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
	<1303392693-1350-3-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43112
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752973Ab1D1GKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 02:10:24 -0400
In-Reply-To: <1303392693-1350-3-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Thu, 21 Apr 2011 09:31:33 -0400

>  		dest = macvlan_hash_lookup(port, eth->h_dest);
>  		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
> +			dev_queue_xmit_nit(skb, vlan->lowerdev);
>  			unsigned int length = skb->len + ETH_HLEN;
>  			int ret = dest->forward(dest->dev, skb);
>  			macvlan_count_rx(dest, length,

Don't put actual code before variable declarations in a basic
block, modern variants of C accept this but this isn't C++.
