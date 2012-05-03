From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 4/4] ixgbe: Fix use after free on module remove
Date: Thu, 03 May 2012 04:22:27 -0400 (EDT)
Message-ID: <20120503.042227.360345661727432549.davem@davemloft.net>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	<20120503071914.13636.31157.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab2ECIWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 04:22:30 -0400
In-Reply-To: <20120503071914.13636.31157.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 03 May 2012 00:19:14 -0700

> While testing the TCP changes I had to fix an issue in order to be able to
> load and unload the module.
> 
> The recent patch that added thermal sensor support added a use after free
> bug on module unload with an 82598 adapter in the system.  To resolve the
> issue I have updated the code so that when we free the info_kobj we set it
> back to NULL.
> 
> I suspect there are likely other bugs present, but I will leave that for
> another patch that can undergo more testing.
> 
> I am submitting this directly to net-next since this fixes a fairly serious
> bug that will lock up the ixgbe module until the system is rebooted.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
