From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] act_csum: fix possible use after free
Date: Fri, 12 Apr 2013 15:26:32 -0400 (EDT)
Message-ID: <20130412.152632.20238206944344935.davem@davemloft.net>
References: <1365790067.4459.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, baronchon@n7mm.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3DLT0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:26:34 -0400
In-Reply-To: <1365790067.4459.56.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Apr 2013 11:07:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tcf_csum_skb_nextlayer() / pskb_may_pull() can change skb->head, so we
> must be careful not keeping pointers to previous headers.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next, but please remind me to apply this to 'net' and
queue up for -stable after it's sit there for a while.

Thanks.
