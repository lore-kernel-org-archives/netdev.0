From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] be2net: event queue re-design
Date: Mon, 13 Feb 2012 00:50:39 -0500 (EST)
Message-ID: <20120213.005039.2089427757739596767.davem@davemloft.net>
References: <1328846727-9465-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab2BMFun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 00:50:43 -0500
In-Reply-To: <1328846727-9465-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 10 Feb 2012 09:35:27 +0530

> v2: Fixed up the bad typecasting pointed out by David...
> 
> In the current design 8 TXQs are serviced by 1 EQ, while each RSS queue
> is serviced by a separate EQ. This is being changed as follows:
> 
> - Upto 8 EQs will be used (based on the availabilty of msix vectors).
> Each EQ will handle 1 RSS and 1 TX ring. The default non-RSS RX queue and
> MCC queue are handled by the last EQ.
> 
> - On cards which provide support, upto 8 RSS rings will be used, instead
> of the current limit of 4.
> 
> The new design allows spreading the TX multi-queue completion processing
> across multiple CPUs unlike the previous design.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
