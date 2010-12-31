From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfq: fix slot_dequeue_head()
Date: Fri, 31 Dec 2010 12:49:04 -0800 (PST)
Message-ID: <20101231.124904.116371515.davem@davemloft.net>
References: <1293721368.7150.307.camel@edumazet-laptop>
	<20101230174918.GA2018@del.dom.local>
	<1293744669.2973.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753156Ab0LaUsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:48:33 -0500
In-Reply-To: <1293744669.2973.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Dec 2010 22:31:09 +0100

> [PATCH v2 net-next-2.6] sfq: fix slot_dequeue_head()
> 
> slot_dequeue_head() should make sure slot skb chain is correct in both
> ways, or we can crash if all possible flows are in use.
> 
> Jarek pointed out slot_queue_init() can now be done in sfq_init() once,
> instead each time a flow is setup.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks.
