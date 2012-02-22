From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: MSG_TRUNC support for dgram sockets
Date: Wed, 22 Feb 2012 14:50:28 -0500 (EST)
Message-ID: <20120222.145028.911050172843464062.davem@davemloft.net>
References: <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120215.145511.1269077904303781879.davem@davemloft.net>
	<1329902695.18384.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: piergiorgio.beruto@gmail.com, netdev@vger.kernel.org,
	mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab2BVTub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 14:50:31 -0500
In-Reply-To: <1329902695.18384.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Feb 2012 10:24:55 +0100

> Piergiorgio Beruto expressed the need to fetch size of first datagram in
> queue for AF_UNIX sockets and suggested a patch against SIOCINQ ioctl.
> 
> I suggested instead to implement MSG_TRUNC support as a recv() input
> flag, as already done for RAW, UDP & NETLINK sockets.
> 
> len = recv(fd, &byte, 1, MSG_PEEK | MSG_TRUNC);
> 
> MSG_TRUNC asks recv() to return the real length of the packet, even when
> is was longer than the passed buffer.
> 
> There is risk that a userland application used MSG_TRUNC by accident
> (since it had no effect on af_unix sockets) and this might break after
> this patch.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
> CC: Michael Kerrisk <mtk.manpages@gmail.com>

Applied.
