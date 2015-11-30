From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers: net: xgene: fix possible use after free
Date: Sun, 29 Nov 2015 22:52:14 -0500 (EST)
Message-ID: <20151129.225214.564332641043989256.davem@davemloft.net>
References: <1448468256.24696.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151125163402.GA29094@leverpostej>
	<1448470930.24696.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, isubramanian@apm.com, netdev@vger.kernel.org,
	kchudgar@apm.com, linux-kernel@vger.kernel.org,
	ryabinin.a.a@gmail.com, linux-arm-kernel@lists.infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbbK3DwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:52:16 -0500
In-Reply-To: <1448470930.24696.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Nov 2015 09:02:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Once TX has been enabled on a NIC, it is illegal to access skb,
> as this skb might have been freed by another cpu, from TX completion
> handler.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Mark Rutland <mark.rutland@arm.com>
> Tested-by: Mark Rutland <mark.rutland@arm.com>

Applied, thanks Eric.
