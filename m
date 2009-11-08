From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in
 rawv6_bind()
Date: Sun, 08 Nov 2009 00:44:18 -0800 (PST)
Message-ID: <20091108.004418.242588768.davem@davemloft.net>
References: <4AF40022.6050100@gmail.com>
	<4AF4536E.7090803@hp.com>
	<4AF4565D.2070207@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53193
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753107AbZKHInw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:43:52 -0500
In-Reply-To: <4AF4565D.2070207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Nov 2009 18:01:17 +0100

> [PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in rawv6_bind()
> 
> Using RCU helps not touching device refcount in rawv6_bind()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
