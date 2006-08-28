From: David Miller <davem@davemloft.net>
Subject: Re: divide error: 0000 in fib6_rule_match
Date: Mon, 28 Aug 2006 14:51:24 -0700 (PDT)
Message-ID: <20060828.145124.120445347.davem@davemloft.net>
References: <20060826160922.3324a707.akpm@osdl.org>
	<20060828200716.GA4244@inferi.kami.home>
	<20060828143003.aaae0d7d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: malattia@linux.it, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43709
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932202AbWH1VvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 17:51:21 -0400
To: akpm@osdl.org
In-Reply-To: <20060828143003.aaae0d7d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 28 Aug 2006 14:30:03 -0700

> Oh.  It looks like this has already been fixed:
> 
> #ifdef CONFIG_IPV6_ROUTE_FWMARK
>         if ((r->fwmark ^ fl->fl6_fwmark) & r->fwmask)
>                 return 0;
> #endif
> 
> there's no divide in there now.

That's right there used to be a typo there.
