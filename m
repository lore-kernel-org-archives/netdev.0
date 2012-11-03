From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] eth: Rename and properly align
 br_reserved_address array
Date: Fri, 02 Nov 2012 21:34:49 -0400 (EDT)
Message-ID: <20121102.213449.167077069602550384.davem@davemloft.net>
References: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	john.r.fastabend@intel.com, shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757380Ab2KCBev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:34:51 -0400
In-Reply-To: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Nov 2012 19:12:02 +0000

> Since this array is no longer part of the bridge driver, it should
> have an 'eth' prefix not 'br'.
> 
> We also assume that either it's 16-bit-aligned or the architecture has
> efficient unaligned access.  Ensure the first of these is true by
> explicitly aligning it.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
