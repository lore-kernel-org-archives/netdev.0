From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Do not define km_migrate() if !CONFIG_XFRM_MIGRATE
Date: Thu, 03 Jan 2008 20:43:43 -0800 (PST)
Message-ID: <20080103.204343.134131840.davem@davemloft.net>
References: <20080103182449.ee02958e.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753346AbYADEnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 23:43:43 -0500
In-Reply-To: <20080103182449.ee02958e.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 3 Jan 2008 18:24:49 +0100

> In include/net/xfrm.h we find :
> 
> #ifdef CONFIG_XFRM_MIGRATE
> extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
>                       struct xfrm_migrate *m, int num_bundles);
> ...
> #endif
> 
> We can also guard the function body itself in net/xfrm/xfrm_state.c
> with same condition.
> 
> (Problem spoted by sparse checker)
> make C=2 net/xfrm/xfrm_state.o
> ...
> net/xfrm/xfrm_state.c:1765:5: warning: symbol 'km_migrate' was not declared. Should it be static?
> ...
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6, thanks Eric.
