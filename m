From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [PPP] pppoe: Fix skb_unshare_check call position
Date: Sun, 16 Sep 2007 16:19:33 -0700 (PDT)
Message-ID: <20070916.161933.45515053.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2Uj-0007MU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753374AbXIPXTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:19:34 -0400
In-Reply-To: <E1IR2Uj-0007MU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:08:49 +0800

> [PPP] pppoe: Fix skb_unshare_check call position
> 
> The skb_unshare_check call needs to be made before pskb_may_pull,
> not after.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Patch applied, thanks Herbert.
