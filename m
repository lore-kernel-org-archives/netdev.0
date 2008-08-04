From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sun, 03 Aug 2008 21:16:07 -0700 (PDT)
Message-ID: <20080803.211607.121999735.davem@davemloft.net>
References: <E1KPpI7-0001jn-00@gondolin.me.apana.org.au>
	<4896703E.1070203@cn.fujitsu.com>
	<20080804030507.GA7091@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, vladislav.yasevich@hp.com,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751092AbYHDEQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 00:16:07 -0400
In-Reply-To: <20080804030507.GA7091@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 4 Aug 2008 11:05:07 +0800

> On Mon, Aug 04, 2008 at 10:58:06AM +0800, Wei Yongjun wrote:
> >
> > You need this patch to let sctp under IPv6 do the correct thing.
> 
> Good point.
> 
> > ipv6: Do not drop packet if skb->local_df is set to true
> > 
> > The old code will drop IPv6 packet if ipfragok is not set, since ipfragok is
> > obsoleted, will be instead by used skb->local_df, so this check must be 
> > changed
> > to skb->local_df.
> > 
> > This patch fix this problem and not drop packet if skb->local_df is set to
> > true.
> > 
> > Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks everyone.
