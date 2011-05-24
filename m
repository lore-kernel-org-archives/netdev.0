From: David Miller <davem@davemloft.net>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 13:30:14 -0400 (EDT)
Message-ID: <20110524.133014.1971739864091124495.davem@davemloft.net>
References: <20110524074156.58eb30f8@nehalam>
	<1306251543.3026.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1EXRaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:30:23 -0400
In-Reply-To: <1306251543.3026.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 May 2011 17:39:03 +0200

> [PATCH] net: fix __dst_destroy_metrics_generic()
> 
> dst_default_metrics is readonly, we dont want to kfree() it later.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Good catch, applied, thanks.
