From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hp100: fix an skb->len race
Date: Sun, 19 Jun 2011 16:34:10 -0700 (PDT)
Message-ID: <20110619.163410.433934092145930996.davem@davemloft.net>
References: <1308508398.3539.80.camel@edumazet-laptop>
	<20110619.120536.1593516819440469613.davem@davemloft.net>
	<1308523413.3539.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab1FSXeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:34:12 -0400
In-Reply-To: <1308523413.3539.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 00:43:33 +0200

> As soon as skb is given to hardware and spinlock released, TX completion
> can free skb under us. Therefore, we should update netdev stats before
> spinlock release.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
