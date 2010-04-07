From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] caching bundles, iteration 5
Date: Wed, 07 Apr 2010 03:52:42 -0700 (PDT)
Message-ID: <20100407.035242.208352211.davem@davemloft.net>
References: <1270636207-20933-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938Ab0DGKwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:52:39 -0400
In-Reply-To: <1270636207-20933-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Wed,  7 Apr 2010 13:30:03 +0300

> Changes:
> - ops->delete() is now called if flow_cache_genid was changed to
>   ensure that resolver does not use stale data
> - removed bumping of policy->genid when inserting new policy since
>   flow_cache_genid ensures everything is regenerated (thanks Herbert!)
> - added unlikely/likely to flow_cache_lookup to favor fast path
>   (cache hit)
> - added herbert's ack to 1/4 
> 
> Compiles, boots and VPN goes up on my test box. Earlier iterations
> tested to stay up 3+ days without noticing leaks or other problems.

Applied to net-next-2.6 and going through some built tests before
I push it out, thanks!
