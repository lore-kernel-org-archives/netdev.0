From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: use napi_schedule_irqoff()
Date: Thu, 30 Oct 2014 16:51:05 -0400 (EDT)
Message-ID: <20141030.165105.1476044007287620552.davem@davemloft.net>
References: <1414627670.631.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161089AbaJ3UvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:51:07 -0400
In-Reply-To: <1414627670.631.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Oct 2014 17:07:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> bnx2x_msix_fp_int() and bnx2x_interrupt() run from hard interrupt
> context.
> 
> They can use napi_schedule_irqoff() instead of napi_schedule()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
