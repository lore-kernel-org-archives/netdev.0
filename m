From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: batch skb dequeueing from softnet input_pkt_queue
Date: Mon, 12 Apr 2010 21:44:53 -0700 (PDT)
Message-ID: <20100412.214453.57473458.davem@davemloft.net>
References: <1271155268-2999-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733Ab0DMEot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 00:44:49 -0400
In-Reply-To: <1271155268-2999-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 13 Apr 2010 18:41:08 +0800

> batch skb dequeueing from softnet input_pkt_queue to reduce potential lock
> contention and irq disabling/enabling.

In exchange for a bunch of new atomic operations.

No, thanks.
