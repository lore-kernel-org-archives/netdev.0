From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 15:27:34 -0500 (EST)
Message-ID: <20111122.152734.1823043516337464576.davem@davemloft.net>
References: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AED9@saturn3.aculab.com>
	<20111122164602.GC25127@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757619Ab1KVU1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:27:40 -0500
In-Reply-To: <20111122164602.GC25127@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 22 Nov 2011 19:46:02 +0300

> Current addr_match() is errh, under-optimized.
> 
> Compiler doesn't know that memcmp() branch doesn't trigger for IPv4.
> Also, pass addresses by value -- they fit into register.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks.
