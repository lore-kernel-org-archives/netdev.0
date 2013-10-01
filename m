From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_is_gso_v6() requires skb_is_gso()
Date: Mon, 30 Sep 2013 22:11:48 -0700 (PDT)
Message-ID: <20130930.221148.1310945488170996031.davem@davemloft.net>
References: <1380442892.3596.22.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3JAFEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:04:41 -0400
In-Reply-To: <1380442892.3596.22.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Sep 2013 01:21:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> bnx2x makes a dangerous use of skb_is_gso_v6().
> 
> It should first make sure skb is a gso packet
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>

Applied.
