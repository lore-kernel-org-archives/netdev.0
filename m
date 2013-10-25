From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: initialize hashrnd in flow_dissector
 with net_get_random_once
Date: Fri, 25 Oct 2013 19:04:30 -0400 (EDT)
Message-ID: <20131025.190430.574644774499501978.davem@davemloft.net>
References: <20131023111219.GA31531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab3JYXEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:04:31 -0400
In-Reply-To: <20131023111219.GA31531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 23 Oct 2013 13:12:19 +0200

> We also can defer the initialization of hashrnd in flow_dissector
> to its first use. Since net_get_random_once is irqsave now we don't
> have to audit the call paths if one of this functions get called by an
> interrupt handler.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
