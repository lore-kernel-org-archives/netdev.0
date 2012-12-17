From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: reset network header before calling
 skb_get_rxhash()
Date: Mon, 17 Dec 2012 12:33:11 -0800 (PST)
Message-ID: <20121217.123311.1003355345453159139.davem@davemloft.net>
References: <20121217081121.GA24173@shutemov.name>
	<CAD6jFUTXP-XgwFeyN11bfGcbiit=aUOoP7sSm64WK+4s6tg2TQ@mail.gmail.com>
	<1355755160.10504.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danborkmann@iogearbox.net, kirill@shutemov.name,
	maxk@qti.qualcomm.com, netdev@vger.kernel.org, dwmw2@infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab2LQUdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 15:33:14 -0500
In-Reply-To: <1355755160.10504.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Dec 2012 06:39:20 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 499744209b2c (tuntap: dont use skb after netif_rx_ni(skb))
> introduced another bug.
> 
> skb_get_rxhash() needs to access the network header, and it was
> set for us in netif_rx_ni().
> 
> We need to reset network header or else skb_flow_dissect() behavior
> is out of control.
> 
> Reported-and-tested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Tested-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, hopefully we've really resolved this fully now :)
