From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [BRIDGE]: Kill clone argument to br_flood_*
Date: Sun, 16 Sep 2007 16:21:00 -0700 (PDT)
Message-ID: <20070916.162100.126763410.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2V8-0007NE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753878AbXIPXVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:21:01 -0400
In-Reply-To: <E1IR2V8-0007NE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:14 +0800

> [BRIDGE]: Kill clone argument to br_flood_*
> 
> The clone argument is only used by one caller and that caller can clone
> the packet itself.  This patch moves the clone call into the caller and
> kills the clone argument.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
