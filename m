From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tipc: Optimize handling excess content on
 incoming messages
Date: Thu, 09 Sep 2010 21:33:44 -0700 (PDT)
Message-ID: <20100909.213344.212697811.davem@davemloft.net>
References: <1283538822-25718-3-git-send-email-paul.gortmaker@windriver.com>
	<20100903.125533.173857867.davem@davemloft.net>
	<20100908233124.GA20563@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750801Ab0IJEd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 00:33:26 -0400
In-Reply-To: <20100908233124.GA20563@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 8 Sep 2010 19:31:24 -0400

> Subject: [PATCH] tipc: Optimize handling excess content on incoming messages
> 
> Remove code that trimmed excess trailing info from incoming messages
> arriving over an Ethernet interface.  TIPC now ignores the extra info
> while the message is being processed by the node, and only trims it off
> if the message is retransmitted to another node.  (This latter step is
> done to ensure the extra info doesn't cause the sk_buff to exceed the
> outgoing interface's MTU limit.) The outgoing buffer is guaranteed to
> be linear.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
