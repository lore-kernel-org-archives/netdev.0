From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 15:52:19 -0400 (EDT)
Message-ID: <20110830.155219.431579142669857208.davem@davemloft.net>
References: <20110830.140733.146208373221522199.davem@davemloft.net>
	<1314731803.2556.4.camel@edumazet-laptop>
	<1314733459.2556.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756497Ab1H3TxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 15:53:00 -0400
In-Reply-To: <1314733459.2556.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Aug 2011 21:44:19 +0200

> Status on FreeBSD 8.1-RELEASE
> 
> bind(AF_UNSPEC) is accepted (converted to AF_INET), only with a 0.0.0.0
> address.
> 
> Following code works :
> 
> struct sockaddr_in addr;
> fd = socket(PF_INET, SOCK_STREAM, 0);
> memset(&addr, 0, sizeof(addr))
> bind(fd, (struct sockaddr *)&addr, sizeof(addr)); -> 0
> 
> If tried on ipv6 sockets, it doesnt work : bind() returns -1, errno=47

Ok if we could add that 0.0.0.0 check too that would make me feel
better about this change.
