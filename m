From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 30 Oct 2009 12:26:40 -0700 (PDT)
Message-ID: <20091030.122640.137286305.davem@davemloft.net>
References: <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>
	<4AEACD88.8080108@gmail.com>
	<4AEB0059.1050400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: francis.moro@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755838AbZJ3T0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:26:15 -0400
In-Reply-To: <4AEB0059.1050400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Oct 2009 16:03:53 +0100

> [PATCH take2] net: fix sk_forward_alloc corruption
> 
> On UDP sockets, we must call skb_free_datagram() with socket locked,
> or risk sk_forward_alloc corruption. This requirement is not respected
> in SUNRPC.
> 
> Add a convenient helper, skb_free_datagram_locked() and use it in SUNRPC
> 
> Reported-by: Francis Moreau <francis.moro@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've tentatively applied this to my net-2.6 tree, I won't
push it out until we have positive testing results.
