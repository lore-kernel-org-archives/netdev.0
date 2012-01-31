From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: rcu conversion
Date: Tue, 31 Jan 2012 12:14:31 -0500 (EST)
Message-ID: <20120131.121431.1826507465549191697.davem@davemloft.net>
References: <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989Ab2AaROi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:14:38 -0500
In-Reply-To: <1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 16:18:33 +0100

> In order to be able to support proper RST messages for TCP MD5 flows, we
> need to allow access to MD5 keys without locking listener socket.
> 
> This conversion is a nice cleanup, and shrinks size of timewait sockets
> by 80 bytes.
> 
> IPv6 code reuses generic code found in IPv4 instead of duplicating it.
> 
> Control path uses GFP_KERNEL allocations instead of GFP_ATOMIC.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Beautiful :-)  Applied, thanks for doing this work Eric.
