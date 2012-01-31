From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: rcu conversion
Date: Tue, 31 Jan 2012 12:15:10 -0500 (EST)
Message-ID: <20120131.121510.2256411938697193634.davem@davemloft.net>
References: <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328024317.2297.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab2AaRPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:15:15 -0500
In-Reply-To: <1328024317.2297.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 16:38:37 +0100

> sock_kmalloc() might be the right thing to use instead of kmalloc()

This is almost certainly the case, it's a per-socket memory
resource rather than one shared with other entities in the
stack.  Therefore sock_kmalloc() is most appropriate.
