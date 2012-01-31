From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: use sock_kmalloc() to limit md5 keys
Date: Tue, 31 Jan 2012 16:13:25 -0500 (EST)
Message-ID: <20120131.161325.774867464311960347.davem@davemloft.net>
References: <1328024317.2297.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120131.121510.2256411938697193634.davem@davemloft.net>
	<1328043408.2617.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab2AaVNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 16:13:32 -0500
In-Reply-To: <1328043408.2617.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 21:56:48 +0100

> There is no limit on number of MD5 keys an application can attach to a
> tcp socket.
> 
> This patch adds a per tcp socket limit based
> on /proc/sys/net/core/optmem_max
> 
> With current default optmem_max values, this allows about 150 keys on
> 64bit arches, and 88 keys on 32bit arches.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
