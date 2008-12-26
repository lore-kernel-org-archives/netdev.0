From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 3/3] ixgbe: Fix set_ringparam in ixgbe to use
 the same memory pools.
Date: Fri, 26 Dec 2008 01:36:41 -0800 (PST)
Message-ID: <20081226.013641.144674900.davem@davemloft.net>
References: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
	<20081225090241.13754.31673.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753529AbYLZJgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:36:39 -0500
In-Reply-To: <20081225090241.13754.31673.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Dec 2008 01:02:41 -0800

> The adapter rings are kcalloc()'d, but in set_ringparam() in ixgbe_ethtool,
> we replace that memory from the vmalloc() pool.  This can result in a NULL
> pointer reference when trying to modify the rings at a later time, or on
> device removal.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
