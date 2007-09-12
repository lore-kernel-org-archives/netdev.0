From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 04:12:00 -0700 (PDT)
Message-ID: <20070912.041200.15253216.davem@davemloft.net>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
	<20070912.020525.39165997.davem@davemloft.net>
	<20070912120845.1b2d77dc.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:56863
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966300AbXILLMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:12:33 -0400
In-Reply-To: <20070912120845.1b2d77dc.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Sep 2007 12:08:45 +0200

> Unfortunatly, there is no equivalent for this one. 
> This gives on my Opterons a nice "prefetchnta"
> 
> prefetch(addr) is more like __builtin_prefetch(addr, 0, 3)
> 
> I would like to avoid to zap L2 cache with useless data.
> 
> __builtin_prefetch() is included from gcc 3.1 (2002), so every 
> platform should support it, as linux-2.6 requires gcc 3.2 at least.
> 
> I guess you are going to tell me to first publish a patch to lkml :)

Basically, yes :-)  You won't be the only person to find this
useful.
