From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: avoid false drop_monitor false positives
Date: Sat, 19 May 2012 02:33:18 -0400 (EDT)
Message-ID: <20120519.023318.564812337139908261.davem@davemloft.net>
References: <1337408580.7029.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab2ESGdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:33:23 -0400
In-Reply-To: <1337408580.7029.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 08:23:00 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Call consume_skb() in place of kfree_skb() were appropriate.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
