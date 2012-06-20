From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 00:57:53 -0700 (PDT)
Message-ID: <20120620.005753.545788933895952782.davem@davemloft.net>
References: <20120619.214957.1282277480138040899.davem@davemloft.net>
	<alpine.LFD.2.00.1206200937040.1912@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab2FTH54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:57:56 -0400
In-Reply-To: <alpine.LFD.2.00.1206200937040.1912@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 20 Jun 2012 10:00:37 +0300 (EEST)

> 			if (skb->dev != dst->dev)
> 				dst = NULL;

That makes the most sense.

> 	Also, is it a good idea to hide such optimizations
> in a bit mask:
> 
> sysctl_net_optimizations & 1: optimize for end host
> sysctl_net_optimizations & 2: optimize for router
> ...

God, that's ugly as sin.

We're putting this down into GRO, so people can tune with
an existing knob there as they already do.
