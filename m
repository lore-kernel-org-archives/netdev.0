From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Missing rtnl lock in error recovery
Date: Tue, 02 Jul 2013 12:38:22 -0700 (PDT)
Message-ID: <20130702.123822.1643149765067831568.davem@davemloft.net>
References: <1372567031.18612.94.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, vipul@chelsio.com,
	jay@chelsio.com, shangw@linux.vnet.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932926Ab3GBTiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:38:24 -0400
In-Reply-To: <1372567031.18612.94.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 30 Jun 2013 14:37:11 +1000

> When exercising error injection on IBM pseries machine, I hit the
> following warning:
...
> It appears that t3_resume_ports() is called with the rtnl_lock held from
> the fatal error task but not from the PCI error callbacks. This fixes it.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Looks good, applied and queued up for -stable, thanks!
