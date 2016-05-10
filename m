From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gtp: reload GTPv1 header after pskb_may_pull()
Date: Tue, 10 May 2016 15:57:07 -0400 (EDT)
Message-ID: <20160510.155707.1869469218949663439.davem@davemloft.net>
References: <1462908818-6104-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcEJT5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 15:57:09 -0400
In-Reply-To: <1462908818-6104-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 10 May 2016 21:33:38 +0200

> The GTPv1 header flags indicate the presence of optional extensions
> after this header. Refresh the pointer to the GTPv1 header as skb->head
> might have be reallocated via pskb_may_pull().
> 
> Fixes: 459aa660eb1d ("gtp: add initial driver for datapath of GPRS Tunneling Protocol (GTP-U)")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
