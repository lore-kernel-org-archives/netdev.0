From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/hsr: Remove left-over never-true
 conditional code.
Date: Fri, 11 Jul 2014 15:05:08 -0700 (PDT)
Message-ID: <20140711.150508.417899658136259344.davem@davemloft.net>
References: <20140710210037.GA14669@mwanda>
	<53C00EF8.1040403@alten.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: arvid.brodin@alten.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbaGKWFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 18:05:09 -0400
In-Reply-To: <53C00EF8.1040403@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@alten.se>
Date: Fri, 11 Jul 2014 18:21:12 +0200

> MacAddressB is an array (unsigned char MacAddressB[ETH_ALEN]) and is allocated
> as a part of *node_dst (which is a struct hsr_node). So the condition is always
> false.
> 
> Detected by Dan Carpenter.
> 
> Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>

Applied, thanks.
