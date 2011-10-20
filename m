From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 17:42:32 -0400 (EDT)
Message-ID: <20111020.174232.432401897148828163.davem@davemloft.net>
References: <1319141403.2854.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mason@myri.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab1JTVmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:42:36 -0400
In-Reply-To: <1319141403.2854.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:10:03 +0200

> skb->truesize must account for allocated memory, not the used part of
> it. Doing this work is important to avoid unexpected OOM situations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
