From: David Miller <davem@davemloft.net>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 12:01:49 -0500 (EST)
Message-ID: <20120216.120149.437368615973561397.davem@davemloft.net>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1329400265.3048.178.camel@deadeye>
	<1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, ncardwell@google.com,
	netdev@vger.kernel.org, alekcejk@googlemail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab2BPRB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 12:01:58 -0500
In-Reply-To: <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Feb 2012 16:09:35 +0100

> Not sure why we cant change tcp_grow_window() to take into account
> number of segments in skb ?

Agreed, that's the correct way to deal with these sorts of issues.
