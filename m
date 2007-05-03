From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Thu, 03 May 2007 03:17:27 -0700 (PDT)
Message-ID: <20070503.031727.52094183.davem@davemloft.net>
References: <E1HeM9f-0001Dt-00@gondolin.me.apana.org.au>
	<20070428.231849.59657032.davem@davemloft.net>
	<20070502041222.GA28620@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@sw.ru, netdev@vger.kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, kaber@trash.net,
	dev@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031141AbXECKR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:17:27 -0400
In-Reply-To: <20070502041222.GA28620@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 2 May 2007 14:12:22 +1000

> Dave, thanks for reminding me.  Here it is.
> 
> [NETLINK]: Kill CB only when socket is unused
> 
> Since we can still receive packets until all references to the
> socket are gone, we don't need to kill the CB until that happens.
> This also aligns ourselves with the receive queue purging which
> happens at that point.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
