From: David Miller <davem@davemloft.net>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Mon, 03 May 2010 23:17:43 -0700 (PDT)
Message-ID: <20100503.231743.20921751.davem@davemloft.net>
References: <1272907269.2226.111.camel@edumazet-laptop>
	<20100503.152351.181464355.davem@davemloft.net>
	<1272948225.2407.170.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655Ab0EDGRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:17:36 -0400
In-Reply-To: <1272948225.2407.170.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 May 2010 06:43:45 +0200

> David, if I am not mistaken (not thea yet for me this early morning) the
> tracer you mention is included in kfree_skb(), not in __kfree_skb() :
 ...
> I only copied part of consume_skb() which doesnt call
> trace_kfree_skb() :
 ...
> So I believe my second patch is a bit better : We dont even lock the
> socket in the (rare) case we should not orphan the skb ;)

Right you are.

> [PATCH net-next-2.6] net: skb_free_datagram_locked() fix

I'll apply this, thanks!
