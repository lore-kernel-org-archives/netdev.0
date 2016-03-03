From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 01/10] net/flower: Introduce hardware
 offload support
Date: Thu, 03 Mar 2016 12:30:33 -0500 (EST)
Message-ID: <20160303.123033.1239966579179656570.davem@davemloft.net>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
	<1457016960-27832-2-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com, saeedm@mellanox.com,
	hadarh@mellanox.com, ronye@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbcCCRag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 12:30:36 -0500
In-Reply-To: <1457016960-27832-2-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Thu,  3 Mar 2016 16:55:51 +0200

> @@ -454,11 +501,13 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  		     u32 handle, struct nlattr **tca,
>  		     unsigned long *arg, bool ovr)
>  {
> +	struct net_device *dev = tp->q->dev_queue->dev;
>  	struct cls_fl_head *head = rtnl_dereference(tp->root);

This variable is not used.

And the compiler warns about this, and because of this I am pretty sure you
aren't looking at the compiler output while testing your builds which is a
big no-no.
