From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: dont set skb->truesize
Date: Tue, 21 Sep 2010 13:04:30 -0700 (PDT)
Message-ID: <20100921.130430.104060821.davem@davemloft.net>
References: <99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
	<20100921.123338.71122967.davem@davemloft.net>
	<1285098910.2452.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754471Ab0IUUEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 16:04:10 -0400
In-Reply-To: <1285098910.2452.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Sep 2010 21:55:10 +0200

> BTW, drivers/net/netxen/netxen_nic_init.c has same problem.
> 
> [PATCH] netxen: dont set skb->truesize

Applied to net-2.6, and I backported the qlcnic patch in net-next-2.6
into net-2.6 too.

Thanks.
