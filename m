From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: make net_get_random_once irqsave
Date: Fri, 25 Oct 2013 19:04:24 -0400 (EDT)
Message-ID: <20131025.190424.652347121699462995.davem@davemloft.net>
References: <20131023111200.GB26236@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab3JYXE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:04:26 -0400
In-Reply-To: <20131023111200.GB26236@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 23 Oct 2013 13:12:00 +0200

> I initial build a non-irqsave version of net_get_random_once because I
> would liked to have the freedom to defer even the extraction process of
> get_random_bytes until the nonblocking pool is fully seeded.
> 
> I don't think this is a good idea anymore and thus this patch makes
> net_get_random_once irqsave. Now someone using net_get_random_once does
> not need to care from where it is called.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
