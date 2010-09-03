From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add special mode accept_ra=2 to accept RA while
 configured as router
Date: Fri, 03 Sep 2010 09:43:28 -0700 (PDT)
Message-ID: <20100903.094328.58433897.davem@davemloft.net>
References: <20100903125914.GA28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755973Ab0ICQnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:43:11 -0400
In-Reply-To: <20100903125914.GA28460@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Fri, 3 Sep 2010 08:59:14 -0400

> The current IPv6 behavior is to not accept router advertisements while
> forwarding, i.e. configured as router.
> 
> This does make sense, a router is typically not supposed to be auto
> configured. However there are exceptions and we should allow the
> current behavior to be overwritten.
> 
> Therefore this patch enables the user to overrule the "if forwarding
> enabled then don't listen to RAs" rule by setting accept_ra to the
> special value of 2.
> 
> An alternative would be to ignore the forwarding switch alltogether
> and solely accept RAs based on the value of accept_ra. However, I
> found that if not intended, accepting RAs as a router can lead to
> strange unwanted behavior therefore we it seems wise to only do so
> if the user explicitely asks for this behavior.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied.
