From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: check return value of ipv6_get_lladdr
Date: Mon, 24 Jun 2013 00:30:17 +0200
Message-ID: <20130623223017.GE13836@order.stressinduktion.org>
References: <20130623195648.GC13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33149 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab3FWWaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 18:30:19 -0400
Content-Disposition: inline
In-Reply-To: <20130623195648.GC13836@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 09:56:48PM +0200, Hannes Frederic Sowa wrote:
> We should check the return value of ipv6_get_lladdr in inet6_set_iftoken.
> 
> A possible situation, which could leave ll_addr unassigned is, when
> the user removed her link-local address but a global scoped address was
> already set. In this case the interface would still be IF_READY and not
> dead. In that case the RS source address is some value from the stack.
> 
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Maybe -net, or even stable?

Actually, stable is nonsense because tokenized ipv6 addresses first
appeared in v3.10-rc1 in mainline.

Greetings,

  Hannes
