From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: Add SNMP counter for DEFER_ACCEPT
Date: Sun, 21 Mar 2010 18:32:32 -0700 (PDT)
Message-ID: <20100321.183232.123981427.davem@davemloft.net>
References: <1269013038.3048.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753744Ab0CVBcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:32:09 -0400
In-Reply-To: <1269013038.3048.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 16:37:18 +0100

> Its currently hard to diagnose when ACK frames are dropped because an
> application set TCP_DEFER_ACCEPT on its listening socket.
> 
> See http://bugzilla.kernel.org/show_bug.cgi?id=15507
> 
> This patch adds a SNMP value, named TCPDeferAcceptDrop
> 
> netstat -s | grep TCPDeferAcceptDrop
>     TCPDeferAcceptDrop: 0
> 
> This counter is incremented every time we drop a pure ACK frame received
> by a socket in SYN_RECV state because its SYNACK retrans count is lower
> than defer_accept value.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
