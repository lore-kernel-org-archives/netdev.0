From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] unix: Add /proc/net/unix_peers file
Date: Sun, 04 Dec 2011 13:25:10 -0500 (EST)
Message-ID: <20111204.132510.1708510157080644595.davem@davemloft.net>
References: <4ED7BC37.2030805@parallels.com>
	<4ED7BC6E.3040600@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754919Ab1LDSZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:25:15 -0500
In-Reply-To: <4ED7BC6E.3040600@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 01 Dec 2011 21:42:06 +0400

> Currently it's not possible to find out what processes are connected
> to each other via a unix socket. In the proposed proc file a socket
> inode number and its peer inode number are shown. With these two at
> hands it's possible to determine the unix connections endpoints.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

I'm basically against new networking procfs based information
retrieval mechanisms.

Please extend the netlink socket dumping so that it works with
AF_UNIX sockets and subsequently added the necessary netlink
attribute to provide the peer value.

I plan to stand pretty firm on this, so you may want to save your
effort and use said effort to implement this properly.

Thanks.
