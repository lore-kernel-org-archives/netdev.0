From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: avoid two atomics in
 ipv6_rthdr_rcv()
Date: Mon, 14 Jun 2010 23:14:47 -0700 (PDT)
Message-ID: <20100614.231447.115943126.davem@davemloft.net>
References: <1276526367.2478.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752446Ab0FOGOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:14:35 -0400
In-Reply-To: <1276526367.2478.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jun 2010 16:39:27 +0200

> Use __in6_dev_get() instead of in6_dev_get()/in6_dev_put()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
