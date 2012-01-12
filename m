From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: introduce mdiobus_alloc_size()
Date: Thu, 12 Jan 2012 15:23:59 -0800 (PST)
Message-ID: <20120112.152359.587415962225564570.davem@davemloft.net>
References: <1325876913-20363-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756142Ab2ALXYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 18:24:03 -0500
In-Reply-To: <1325876913-20363-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Fri, 6 Jan 2012 13:08:33 -0600

> Introduce function mdiobus_alloc_size() as an alternative to mdiobus_alloc().
> Most callers of mdiobus_alloc() also allocate a private data structure, and
> then manually point bus->priv to this object.  mdiobus_alloc_size()
> combines the two operations into one, which simplifies memory management.
> 
> The original mdiobus_alloc() now just calls mdiobus_alloc_size(0).
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied, thanks.
