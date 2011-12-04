From: David Miller <davem@davemloft.net>
Subject: Re: SYN attack, with FIN flag set
Date: Sun, 04 Dec 2011 01:26:11 -0500 (EST)
Message-ID: <20111204.012611.1174460605712653029.davem@davemloft.net>
References: <4ED9E5FA.30204@msgid.tls.msk.ru>
	<73da1a18b48dc3097acd6728be208c66@visp.net.lb>
	<1322905302.2762.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, mjt@tls.msk.ru, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab1LDG0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 01:26:34 -0500
In-Reply-To: <1322905302.2762.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Dec 2011 10:41:42 +0100

> [PATCH] tcp: drop SYN+FIN messages
> 
> Denys Fedoryshchenko reported that SYN+FIN attacks were bringing his
> linux machines to their limits.
> 
> Dont call conn_request() if the TCP flags includes SYN flag
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, I've applied this to net-next.
