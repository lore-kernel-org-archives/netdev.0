From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: fix crash on iface up with shirq debug
Date: Wed, 18 Mar 2009 18:49:13 -0700 (PDT)
Message-ID: <20090318.184913.51238325.davem@davemloft.net>
References: <20090315053552.GH3167@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org, davej@redhat.com
To: kyle@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751884AbZCSBt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:49:26 -0400
In-Reply-To: <20090315053552.GH3167@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@infradead.org>
Date: Sun, 15 Mar 2009 01:35:52 -0400

> Tulip is currently doing request_irq before it has done its
> initialization. This is usually not a problem because it hasn't
> enable interrupts yet, but with DEBUG_SHIRQ on, we call the irq handler
> when registering the interrupt as a sanity check.
> 
> This can result in a NULL ptr dereference, so call tulip_init_ring
> before request_irq, and add a free_ring function to do the freeing
> now shared with tulip_close.
> 
> Tested with a shell loop running ifup, ifdown in a loop a few hundred
> times with DEBUG_SHIRQ on.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

Applied, thanks.
