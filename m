From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [PPP] generic: Fix receive path data clobbering &
 non-linear handling
Date: Sun, 16 Sep 2007 16:22:26 -0700 (PDT)
Message-ID: <20070916.162226.75430184.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2VB-0007Nc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60857
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753935AbXIPXW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:22:26 -0400
In-Reply-To: <E1IR2VB-0007Nc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:17 +0800

> [PPP] generic: Fix receive path data clobbering & non-linear handling
> 
> This patch adds missing pskb_may_pull calls to deal with non-linear
> packets that may arrive from pppoe or pppol2tp.
> 
> It also copies cloned packets before writing over them.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
