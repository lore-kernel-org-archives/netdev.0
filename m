From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] udp: use atomic_inc_not_zero_hint
Date: Tue, 16 Nov 2010 11:35:19 -0800 (PST)
Message-ID: <20101116.113519.245394130.davem@davemloft.net>
References: <1289887106.3364.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756408Ab0KPTey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:34:54 -0500
In-Reply-To: <1289887106.3364.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Nov 2010 06:58:26 +0100

> UDP sockets refcount is usually 2, unless an incoming frame is going to
> be queued in receive or backlog queue.
> 
> Using atomic_inc_not_zero_hint() permits to reduce latency, because
> processor issues less memory transactions.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
