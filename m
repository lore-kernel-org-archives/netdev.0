From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Fri, 23 Dec 2011 16:52:47 -0500 (EST)
Message-ID: <20111223.165247.1508204992154625980.davem@davemloft.net>
References: <20111222.132024.2100751924070475608.davem@davemloft.net>
	<45B8991A987A4149B40F1A061BF49097B96C9EFF05@LONPMAILBOX01.citrite.net>
	<1324633155.7877.106.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611Ab1LWVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 16:52:53 -0500
In-Reply-To: <1324633155.7877.106.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 23 Dec 2011 09:39:14 +0000

> Subject: [PATCH] net: only use a single page of slop in MAX_SKB_FRAGS
> 
> In order to accommodate a 64K buffer we need 64K/PAGE_SIZE plus one more page
> in order to allow for a buffer which does not start on a page boundary.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
