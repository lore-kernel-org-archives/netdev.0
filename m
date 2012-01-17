From: David Miller <davem@davemloft.net>
Subject: Re: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 10:15:18 -0500 (EST)
Message-ID: <20120117.101518.1568994216712302500.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF49@saturn3.aculab.com>
	<20120117161447.5ef681c9@wwwwww-701SD>
	<1326813197.2259.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: abirvalg@lavabit.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab2AQPPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:15:22 -0500
In-Reply-To: <1326813197.2259.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2012 16:13:17 +0100

> One sendmsg() for the request, one recvmsg() for the answer (with _all_
> details included), even if your /proc/net/tcp*** has 1.000.000 lines.
> 
> Really say no to /proc files.

Indeed.
