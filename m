From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: populate skb->l4_rxhash
Date: Mon, 09 Jul 2012 14:41:38 -0700 (PDT)
Message-ID: <20120709.144138.175797978214615404.davem@davemloft.net>
References: <1341849744.3265.3219.camel@edumazet-glaptop>
	<1341850532.27035.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, willemb@google.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab2GIVlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:41:39 -0400
In-Reply-To: <1341850532.27035.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 9 Jul 2012 19:15:32 +0300

> On Mon, 2012-07-09 at 18:02 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> l4_rxhash is set on skb when rxhash is obtained from canonical 4-tuple
>> over transport ports/addresses.
>> 
>> We can set skb->l4_rxhash for all incoming TCP packets on bnx2x for
>> free, as cqe status contains a hash type information.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
...
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
