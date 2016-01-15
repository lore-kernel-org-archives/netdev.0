From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netfront: request Tx response events more
 often
Date: Fri, 15 Jan 2016 14:58:46 -0500 (EST)
Message-ID: <20160115.145846.2281196804935039066.davem@davemloft.net>
References: <1452859002-18543-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	malcolm.crossley@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbcAOT6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 14:58:48 -0500
In-Reply-To: <1452859002-18543-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Fri, 15 Jan 2016 11:56:42 +0000

> @@ -364,6 +364,7 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
>  	RING_IDX cons, prod;
>  	unsigned short id;
>  	struct sk_buff *skb;
> +	int more_to_do;

I hate to be difficult, but could you please use 'bool' for this variable?

Thanks!
