From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: use htons for skb->protocol
Date: Tue, 29 Jun 2010 15:17:40 -0700 (PDT)
Message-ID: <20100629.151740.135534374.davem@davemloft.net>
References: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754537Ab0F2WR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:17:27 -0400
In-Reply-To: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Tue, 29 Jun 2010 18:32:46 +0200

> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> This is only noticed by people that are not doing everything correct in
> the first place.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

It's in network byte order so you should use ntohs().
