From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Fri, 16 Nov 2007 16:54:45 -0800 (PST)
Message-ID: <20071116.165445.172804063.davem@davemloft.net>
References: <20071116174027.726e6eca.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752852AbXKQAyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 19:54:45 -0500
In-Reply-To: <20071116174027.726e6eca.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 16 Nov 2007 17:40:27 +0100

> +	unsigned long fake = 0, *flag_ptr;
 ...
> +		/*
> +		 * This is a fast version of :
> +		 * if (process_context && need_resched())
> +		 */
> +		if (unlikely(test_bit(TIF_NEED_RESCHED, flag_ptr)))
> +			cond_resched();

Too much exposure to internals for me to apply this, really.

I have no problem with the change conceptually at all, this
detail is just too dirty.
