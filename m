From: David Miller <davem@davemloft.net>
Subject: Re: [patch] [IrDA]: small read past the end of array in debug code
Date: Fri, 19 Apr 2013 17:33:29 -0400 (EDT)
Message-ID: <20130419.173329.1993060022855519678.davem@davemloft.net>
References: <20130417071038.GA7923@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933525Ab3DSVdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:33:31 -0400
In-Reply-To: <20130417071038.GA7923@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 17 Apr 2013 10:10:38 +0300

> The "reason" can come from skb->data[] and it hasn't been capped so it
> can be from 0-255 instead of just 0-6.  For example in irlmp_state_dtr()
> the code does:
> 
> 	reason = skb->data[3];
> 	...
> 	irlmp_disconnect_indication(self, reason, skb);
> 
> Also LMREASON has a couple other values which don't have entries in the
> irlmp_reasons[] array.  And 0xff is a valid reason as well which means
> "unknown".
> 
> So far as I can see we don't actually care about "reason" except for in
> the debug code.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied but please put the subsystem prefix outside of [] which get
stripped by git am and other tools.  I fixed it up to be "irda: ".

Thanks.
