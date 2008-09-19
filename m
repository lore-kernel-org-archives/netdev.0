From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 12:38:01 +0100
Message-ID: <1221824281.3103.8.camel@achroite>
References: <20080918.193815.175549834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33713 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751734AbYISLiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 07:38:09 -0400
In-Reply-To: <20080918.193815.175549834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-09-18 at 19:38 -0700, David Miller wrote:
[...]
> So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> have names like:
> 
> 	eth0-rx-0
> 	eth0-rx-1
> 	eth0-tx-0
> 	eth0-tx-1
> 
> So let's make an effort to get this done right in 2.6.28 and meanwhile
> Arjan can add the irqbalanced code.

What about the case where an interrupt is shared between RX and TX
completions?  Our hardware is very flexible in this regard, but based on
performance testing prior to the introduction of TX multiqueue we
currently allocate multiple interrupts for RX completions and share the
first with TX completions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

