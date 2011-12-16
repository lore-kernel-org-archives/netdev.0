From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sch_sfq: store flow_keys in skb->cb[]
Date: Fri, 16 Dec 2011 13:54:20 -0500 (EST)
Message-ID: <20111216.135420.664062202208615256.davem@davemloft.net>
References: <1324013979.2562.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198Ab1LPSyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:54:25 -0500
In-Reply-To: <1324013979.2562.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Dec 2011 06:39:39 +0100

> Instead of using automatic flow_keys variable in sfq_hash(), use storage
> from skb->cb[] so that we can reuse it later if we want to rehash queues
> when perturbation timer fires.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Where is "2/2"?
