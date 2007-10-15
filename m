From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/10] [BRIDGE]: Unshare skb upon entry
Date: Mon, 15 Oct 2007 01:50:19 -0700 (PDT)
Message-ID: <20071015.015019.01895604.davem@davemloft.net>
References: <20071014042604.GA11431@gondor.apana.org.au>
	<E1Igv4q-00030k-00@gondolin.me.apana.org.au>
	<471314A0.5080500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755575AbXJOIuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:50:20 -0400
In-Reply-To: <471314A0.5080500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Oct 2007 09:20:00 +0200

> Herbert Xu wrote:
> > [BRIDGE]: Unshare skb upon entry
> > 
> > Due to the special location of the bridging hook, it should never see a
> > shared packet anyway (certainly not with any in-kernel code).  So it
> > makes sense to unshare the skb there if necessary as that will greatly
> > simplify the code below it (in particular, netfilter).
> 
> 
> I guess we can remove the unsharing from br_netfilter.c now.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick!
