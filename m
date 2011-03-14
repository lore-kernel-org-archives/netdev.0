From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: should use call_rcu() variant
Date: Sun, 13 Mar 2011 23:22:39 -0700 (PDT)
Message-ID: <20110313.232239.104044469.davem@davemloft.net>
References: <1300010649.2761.3.camel@edumazet-laptop>
	<20110313.164215.193721466.davem@davemloft.net>
	<1300076131.2761.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752376Ab1CNGWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 02:22:02 -0400
In-Reply-To: <1300076131.2761.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Mar 2011 05:15:31 +0100

> [PATCH net-next-2.6] inetpeer: should use call_rcu() variant
> 
> After commit 7b46ac4e77f3224a (inetpeer: Don't disable BH for initial
> fast RCU lookup.), we should use call_rcu() to wait proper RCU grace
> period.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
