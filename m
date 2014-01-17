From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel][PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 17:25:45 -0800 (PST)
Message-ID: <20140116.172545.698957643976308902.davem@davemloft.net>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com>
	<52D7BE19.2010009@citrix.com>
	<52D7E1BB.8000706@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	andrew.bennieston@citrix.com
To: annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaAQBZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:25:46 -0500
In-Reply-To: <52D7E1BB.8000706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: annie li <annie.li@oracle.com>
Date: Thu, 16 Jan 2014 21:42:19 +0800

> What I thought is to split the implementation into two patches, this
> patch fixes the rx path resource leak(just like what tx path does),
> then a separate patch fixes gnttab_end_foreign_access_ref failure
> issue for both tx/rx through taking reference to the page before
> gnttab_end_foreign_access.
> If you'd like they are posted together, I will create new patch for
> the latter and then post them.:-)

That would probably work best.
