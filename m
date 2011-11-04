From: David Miller <davem@davemloft.net>
Subject: Re: [stable] net: Handle different key sizes between address
 families in flow cache
Date: Fri, 04 Nov 2011 16:41:25 -0400 (EDT)
Message-ID: <20111104.164125.2292522551687012965.davem@davemloft.net>
References: <20111103135851.2229247682ec040d653479e1@freescale.com>
	<20111103.224329.2276058062630695656.davem@davemloft.net>
	<20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, eric.dumazet@gmail.com,
	zheng.z.yan@intel.com, netdev@vger.kernel.org,
	david.ward@ll.mit.edu
To: kim.phillips@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab1KDUld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 16:41:33 -0400
In-Reply-To: <20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Phillips <kim.phillips@freescale.com>
Date: Fri, 4 Nov 2011 14:46:59 -0500

> commit aa1c366e4febc7f5c2b84958a2dd7cd70e28f9d0 upstream.
> 
> With the conversion of struct flowi to a union of AF-specific structs, some
> operations on the flow cache need to account for the exact size of the key.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Cc: stable@vger.kernel.org # v3.0.x

I'm fine with this, -stable folks please apply.

Thanks.
