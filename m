From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_mem initialization
Date: Thu, 15 Mar 2007 02:58:39 -0700 (PDT)
Message-ID: <20070315.025839.104050310.davem@davemloft.net>
References: <45F86842.8040305@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbXCOJ6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 05:58:41 -0400
In-Reply-To: <45F86842.8040305@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Wed, 14 Mar 2007 17:25:22 -0400

> The current tcp_mem initialization gives values that are really too 
> small for systems with ~256-768 MB of memory, and also for systems with 
> larger page sizes (ia64).  This patch gives an alternate method of 
> initialization that doesn't depend on the cache allocation functions, 
> but I think should still provide a nice curve that gives a smaller 
> fraction of total memory with small-memory systems, while maintaining 
> the same upper bound (pressure at 1/2, max as 3/4) on larger memory systems.

Indeed, it's really dumb for any of these calculations to be
dependant upon the page size.

Your patch looks good, and I'll review it further tomorrow and
push upstream unless I find some issues with it.

Thanks John.

