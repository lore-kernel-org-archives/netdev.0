From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Declare netdev_rss_key as
 __read_mostly.
Date: Sat, 06 Feb 2016 03:14:37 -0500 (EST)
Message-ID: <20160206.031437.334705957146638774.davem@davemloft.net>
References: <1454385076-31469-1-git-send-email-kim-marie.jones@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan.carey@intel.com
To: kim-marie.jones@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbcBFIOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:14:41 -0500
In-Reply-To: <1454385076-31469-1-git-send-email-kim-marie.jones@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Jones <kim-marie.jones@intel.com>
Date: Tue,  2 Feb 2016 03:51:16 +0000

> netdev_rss_key is written to once and thereafter is read by
> drivers when they are initialising. The fact that it is mostly
> read and not written to makes it a candidate for a __read_mostly
> declaration.
> 
> Signed-off-by: Kim Jones <kim-marie.jones@intel.com>
> Signed-off-by: Alan Carey <alan.carey@intel.com>
> Acked-by: Rami Rosen <rami.rosen@intel.com>

Applied, thank you.
