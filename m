From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Sat, 28 Apr 2007 23:18:49 -0700 (PDT)
Message-ID: <20070428.231849.59657032.davem@davemloft.net>
References: <20070418.170636.77057313.davem@davemloft.net>
	<E1HeM9f-0001Dt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@sw.ru, netdev@vger.kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, kaber@trash.net,
	dev@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756242AbXD2GSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 02:18:52 -0400
In-Reply-To: <E1HeM9f-0001Dt-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 19 Apr 2007 12:13:51 +1000

> [NETLINK]: Kill CB only when socket is unused
> 
> Since we can still receive packets until all references to the
> socket are gone, we don't need to kill the CB until that happens.
> This also aligns ourselves with the receive queue purging which
> happens at that point.
> 
> Original patch by Pavel Emelianov who noticed this race condition.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Herbert, could you refresh this refinement to the current
tree?

Thanks a lot!
