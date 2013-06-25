From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: check return value of ipv6_get_lladdr
Date: Tue, 25 Jun 2013 16:28:04 -0700 (PDT)
Message-ID: <20130625.162804.328857332762341398.davem@davemloft.net>
References: <20130624194240.GI13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab3FYX2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:28:05 -0400
In-Reply-To: <20130624194240.GI13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 24 Jun 2013 21:42:40 +0200

> We should check the return value of ipv6_get_lladdr in inet6_set_iftoken.
> 
> A possible situation, which could leave ll_addr unassigned is, when
> the user removed her link-local address but a global scoped address was
> already set. In this case the interface would still be IF_READY and not
> dead. In that case the RS source address is some value from the stack.
> 
> v2: Daniel Borkmann noted a small indent inconstancy; no semantic
> changes.
> 
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Reviewed-by: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
