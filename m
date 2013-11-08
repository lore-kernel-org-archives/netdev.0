From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: flow_dissector: small optimizations in
 IPv4 dissect
Date: Fri, 08 Nov 2013 13:30:15 -0500 (EST)
Message-ID: <20131108.133015.2000589866643088644.davem@davemloft.net>
References: <1383842248.9412.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab3KHSaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:30:17 -0500
In-Reply-To: <1383842248.9412.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Nov 2013 08:37:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> By moving code around, we avoid :
> 
> 1) A reload of iph->ihl (bit field, so needs a mask)
> 
> 2) A conditional test (replaced by a conditional mov on x86)
>    Fast path loads iph->protocol anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
