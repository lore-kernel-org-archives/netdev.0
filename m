From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: ethernet: eth: fix some code style issues
Date: Wed, 14 Jul 2010 18:26:30 -0700 (PDT)
Message-ID: <20100714.182630.48510763.davem@davemloft.net>
References: <1279138937-12985-1-git-send-email-chihau@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, opurdila@ixiacom.com,
	netdev@vger.kernel.org, linux-devel@vger.kernel.org,
	mitov@issp.bas.bg
To: chihau@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758067Ab0GOB0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 21:26:14 -0400
In-Reply-To: <1279138937-12985-1-git-send-email-chihau@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chihau Chau <chihau@gmail.com>
Date: Wed, 14 Jul 2010 16:22:17 -0400

> @@ -180,7 +180,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  	 *      seems to set IFF_PROMISC.
>  	 */
>  
> -	else if (1 /*dev->flags&IFF_PROMISC */ ) {
> +	/*dev->flags&IFF_PROMISC */
> +	else if (1) {

This makes the code look worse, not better.

If the commented test is in the parenthesis, it is unambiguous
which piece of code the suggested test is meant for.
