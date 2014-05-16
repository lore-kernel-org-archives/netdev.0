From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Add support for device specific address
 syncing
Date: Fri, 16 May 2014 16:47:28 -0400 (EDT)
Message-ID: <20140516.164728.2297526772904518777.davem@davemloft.net>
References: <53765D5D.9040207@intel.com>
	<20140516.150115.1106293449904617860.davem@davemloft.net>
	<53766D3E.4080904@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaEPUra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:47:30 -0400
In-Reply-To: <53766D3E.4080904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 16 May 2014 12:55:42 -0700

> I can understand going into promisc on a sync failure, but why would you
> do it on an unsync failure, or are you saying that we would be clearing
> the flag in unsync?

We should clear the promisc flag on unsync if the limitations are no
longer exceeded.

> In general I intended for this to be called in set_rx_mode so if
> __dev_uc_sync returns an error indicating insufficient resources we have
> to force IFF_PROMISC on because adding a new address failed.  We could
> also do the same thing for __dev_mc_sync and IFF_ALLMULTI.

Right.
