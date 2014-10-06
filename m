From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: spider_net: fix possible bitops errors
Date: Sun, 05 Oct 2014 21:15:52 -0400 (EDT)
Message-ID: <20141005.211552.452619735296906900.davem@davemloft.net>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:15:54 -0400
In-Reply-To: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Fri,  3 Oct 2014 17:01:53 +0200

> Dan reported a possible signedness issue on the pxa168_eth driver. While
> having a look at it, I came across a similar problem in the spider_net
> driver.
> 
> Here is one proposal to fix it. The first patch rework the
> spider_net_set_mac() function by removing the spider_net_get_mac_address()
> call and using memcpy() to set netdev->dev_addr (which is what's done in
> lots of Ethernet drivers) and the second one fix the actual signedness
> issue.
> 
> If for any reason you really want to keep a call to
> spider_net_get_mac_address() because the memcpy() is somehow not good
> enough here, we can also come up with a solution involving a temporary
> unsigned char variable.

Series applied, thanks.
