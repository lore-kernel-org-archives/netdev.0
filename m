From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: free the right skb
Date: Mon, 06 Aug 2012 13:31:41 -0700 (PDT)
Message-ID: <20120806.133141.1857613274019545568.davem@davemloft.net>
References: <1344256558-22649-1-git-send-email-sdumitru@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: sdumitru@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227Ab2HFUbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:31:41 -0400
In-Reply-To: <1344256558-22649-1-git-send-email-sdumitru@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sorin Dumitru <sdumitru@ixiacom.com>
Date: Mon, 6 Aug 2012 15:35:58 +0300

> We are freeing skb instead of nskb, resulting in a double
> free on skb and a leak from nskb.
> 
> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>

Applied.
