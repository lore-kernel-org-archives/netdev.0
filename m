From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: use napi_schedule_irqoff()
Date: Thu, 30 Oct 2014 16:50:57 -0400 (EDT)
Message-ID: <20141030.165057.520985882742799434.davem@davemloft.net>
References: <1414626885.631.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933947AbaJ3UvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:51:02 -0400
In-Reply-To: <1414626885.631.102.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Oct 2014 16:54:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4_en_rx_irq() and mlx4_en_tx_irq() run from hard interrupt context.
> 
> They can use napi_schedule_irqoff() instead of napi_schedule()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
