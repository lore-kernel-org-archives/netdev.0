From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix a possible crash in ipgre_err()
Date: Mon, 20 May 2013 00:19:38 -0700 (PDT)
Message-ID: <20130520.001938.137427083553027440.davem@davemloft.net>
References: <1368902163.3301.156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399Ab3ETHTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 03:19:39 -0400
In-Reply-To: <1368902163.3301.156.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 May 2013 11:36:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Another fix needed in ipgre_err(), as parse_gre_header() might change
> skb->head.
> 
> Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
