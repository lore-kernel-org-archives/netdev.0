From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/gianfar: drop recycled skbs on MTU change
Date: Mon, 03 May 2010 15:29:37 -0700 (PDT)
Message-ID: <20100503.152937.209596510.davem@davemloft.net>
References: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759112Ab0ECW3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:29:30 -0400
In-Reply-To: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Mon, 3 May 2010 17:17:45 +0200

> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> The size for skb which is added to the recycled list is using the
> current descriptor size which is current MTU. gfar_new_skb() is also
> using this size. So after changing or alteast increasing the MTU all
> recycled skbs should be dropped.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> I'm not 100% sure but it looks like it is wrong.

It looks right to me, can I get an ACK from gianfar developers?
