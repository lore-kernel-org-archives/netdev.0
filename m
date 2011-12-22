From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 13:29:50 -0500 (EST)
Message-ID: <20111222.132950.2105811163837575839.davem@davemloft.net>
References: <1324563353.2153.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4EF352A2.2090604@bootc.net>
	<1324575692.2586.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bootc@bootc.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324575692.2586.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Dec 2011 18:41:32 +0100

> IPv6 needs multicast capabilities, so maybe balance-rr bonding mode is
> not propagating multicat filters properly on both nics.
> 
> It might be a problem on one of your NIC.

This is my impression too, definitely some kind of multicast problem.
