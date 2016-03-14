From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] tipc: make sure IPv6 header fits in skb
 headroom
Date: Mon, 14 Mar 2016 12:23:23 -0400 (EDT)
Message-ID: <20160314.122323.2216969194777127991.davem@davemloft.net>
References: <1457945032-30547-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbcCNQXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:23:25 -0400
In-Reply-To: <1457945032-30547-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 14 Mar 2016 09:43:52 +0100

> Expand headroom further in order to be able to fit the larger IPv6
> header. Prior to this patch this caused a skb under panic for certain
> tipc packets when using IPv6 UDP bearer(s).
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
