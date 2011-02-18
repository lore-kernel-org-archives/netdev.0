From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Add hash table of interface addresses.
Date: Fri, 18 Feb 2011 12:12:53 -0800 (PST)
Message-ID: <20110218.121253.189712244.davem@davemloft.net>
References: <20110217.204638.104041410.davem@davemloft.net>
	<1298010150.2642.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757166Ab1BRUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 15:12:16 -0500
In-Reply-To: <1298010150.2642.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Feb 2011 07:22:30 +0100

> Maybe you should take into account net pointer here, or machines with
> many net namespaces will hash collide for 127.0.0.1

Good idea.  I'll post a new series with that fixed up later.

Thanks!
