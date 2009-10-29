From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Wed, 28 Oct 2009 23:02:32 -0700 (PDT)
Message-ID: <20091028.230232.20877138.davem@davemloft.net>
References: <20091028151313.ba4a4d23.akpm@linux-foundation.org>
	<4AE9298C.1000204@gmail.com>
	<4AE92F4D.6070101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754333AbZJ2GCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 02:02:10 -0400
In-Reply-To: <4AE92F4D.6070101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Oct 2009 06:59:41 +0100

> David, what do you think of following patch ?
> 
> I wonder if we should reorganize code to add sanity checks in tcp_unlink_write_queue()
> that the skb we delete from queue is not still referenced.
> 
> [PATCH] tcp: clear retrans hints in tcp_send_synack()
> 
> There is a small possibility the skb we unlink from write queue 
> is still referenced by retrans hints.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yes, the first thing I thought of when I saw this crash was the hints.

I'll think this over.
