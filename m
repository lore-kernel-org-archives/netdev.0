From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce napi_schedule_irqoff()
Date: Wed, 29 Oct 2014 16:08:10 -0400 (EDT)
Message-ID: <20141029.160810.1578843646427209982.davem@davemloft.net>
References: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436AbaJ2UIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 16:08:12 -0400
In-Reply-To: <1414544713.631.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Oct 2014 18:05:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> napi_schedule() can be called from any context and has to mask hard
> irqs.
> 
> Add a variant that can only be called from hard interrupts handlers
> or when irqs are already masked.
> 
> Many NIC drivers can use it from their hard IRQ handler instead of
> generic variant.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
