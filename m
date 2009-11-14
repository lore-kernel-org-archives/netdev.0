From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: Optimize inet_getid()
Date: Fri, 13 Nov 2009 20:50:57 -0800 (PST)
Message-ID: <20091113.205057.207708747.davem@davemloft.net>
References: <4AFC62F5.60700@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50279
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752795AbZKNEul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:50:41 -0500
In-Reply-To: <4AFC62F5.60700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2009 20:33:09 +0100

> While investigating for network latencies, I found inet_getid() was a
> contention point for some workloads, as inet_peer_idlock is shared
> by all inet_getid() users regardless of peers.
> 
> One way to fix this is to make ip_id_count an atomic_t instead
> of __u16, and use atomic_add_return().
> 
> In order to keep sizeof(struct inet_peer) = 64 on 64bit arches
> tcp_ts_stamp is also converted to __u32 instead of "unsigned long".
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
