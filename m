From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour: reduce exports
Date: Thu, 17 Aug 2006 18:18:08 -0700 (PDT)
Message-ID: <20060817.181808.85411328.davem@davemloft.net>
References: <20060815125630.42ca9451@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44755
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932261AbWHRBR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 21:17:59 -0400
To: shemminger@osdl.org
In-Reply-To: <20060815125630.42ca9451@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 15 Aug 2006 12:56:30 -0700

> There are several symbols only used by rtnetlink and since it can
> not be a module, there is no reason to export them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied.

> -static __inline__ void neigh_update_hhs(struct neighbour *neigh)
> +static void neigh_update_hhs(struct neighbour *neigh)
 ...
> -EXPORT_SYMBOL(neigh_update_hhs);

Nice to see we were trying to export a static inline function :)
