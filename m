From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Fri, 03 Jan 2014 20:51:31 -0500 (EST)
Message-ID: <20140103.205131.1429670011198294911.davem@davemloft.net>
References: <1388756813-10875-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634AbaADBvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:51:33 -0500
In-Reply-To: <1388756813-10875-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Fri,  3 Jan 2014 05:46:53 -0800

> +	if (skb->ip_summed == CHECKSUM_COMPLETE)
> +		NAPI_GRO_CB(skb)->csum = csum_sub(NAPI_GRO_CB(skb)->csum,
> +			csum_partial(start, len, 0));

The csum_partial() call as argument needs to line up to exactly the
first column after the openning parenthesis of the csum_sub()
invocation.

You must use the appropriate number of TAB then SPACE characters
necessary to achieve this.

If you indent only using TABS then likely you are doing it wrong :)
