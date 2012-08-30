From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] net/fsl-pq-mdio: coalesce multiple memory
 allocations into one
Date: Thu, 30 Aug 2012 13:31:09 -0400 (EDT)
Message-ID: <20120830.133109.695328019988288946.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
	<1346263683-3664-6-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab2H3RbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:31:12 -0400
In-Reply-To: <1346263683-3664-6-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:08:02 -0500

> Take advantage of the new mdiobus_alloc_size() function to combine three
> different memory allocations into one.  This also simplies the error
> handling.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
