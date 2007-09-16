From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [PPP] pppoe: Fill in header directly in
 __pppoe_xmit
Date: Sun, 16 Sep 2007 16:20:33 -0700 (PDT)
Message-ID: <20070916.162033.27951608.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2V6-0007N6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753855AbXIPXUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:20:33 -0400
In-Reply-To: <E1IR2V6-0007N6-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:12 +0800

> [PPP] pppoe: Fill in header directly in __pppoe_xmit
> 
> This patch removes the hdr variable (which is copied into the skb)
> and instead sets the header directly in the skb.
> 
> It also uses __skb_push instead of skb_push since we've just checked
> using skb_cow for enough head room.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
