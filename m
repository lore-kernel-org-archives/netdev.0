From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] ipv6: check return value of ipv6_get_lladdr
Date: Mon, 24 Jun 2013 15:22:21 -0300
Message-ID: <20130624182220.GB22786@obelix.rh>
References: <20130623195648.GC13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab3FXSWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 14:22:22 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5OIMMEV025163
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 14:22:22 -0400
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

Reviewed-by: Flavio Leitner <fbl@redhat.com>
