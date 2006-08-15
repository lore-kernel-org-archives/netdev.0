From: David Miller <davem@davemloft.net>
Subject: Re: XFRM_MSG_NEWAE
Date: Tue, 15 Aug 2006 02:16:15 -0700 (PDT)
Message-ID: <20060815.021615.18710100.davem@davemloft.net>
References: <20060815.002852.35359129.davem@davemloft.net>
	<E1GCtxT-0000up-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34708
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965323AbWHOJQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 05:16:13 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1GCtxT-0000up-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 15 Aug 2006 18:07:31 +1000

> David Miller <davem@davemloft.net> wrote:
> > 
> > I think we need a way to tone this down, so that if there are no truly
> > interested parties we don't do the km->notify work at all.
> 
> Actually, we do turn it off if nobody is listening, through
> xfrm_aevent_is_on().

Thanks for pointing that out.
