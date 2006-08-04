From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 4 Aug 2006 09:58:53 +0400
Message-ID: <20060804055853.GA413@2ka.mipt.ru>
References: <20060803135925.GA28348@2ka.mipt.ru> <E1G8sbw-0003mT-00@gondolin.me.apana.org.au> <20060803.225501.77357103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: herbert@gondor.apana.org.au, arnd@arndnet.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41941 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161061AbWHDF7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 01:59:32 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060803.225501.77357103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 10:55:01PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 04 Aug 2006 15:52:40 +1000
> 
> > Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > > 
> > > But it does not support splitting them into page sized chunks, so it
> > > requires the whole jumbo frame allocation in one contiguous chunk, 9k
> > > will be transferred into 16k allocation (order 3), since SLAB uses
> > > power-of-2 allocation.
> > 
> > Actually order 3 is 32KB.

Yep, e1000 align 9k to 16k, then alloc_skb adds shared info and align it
to 32k.

> It's 64KB on my computer :)

Nice overhead...

-- 
	Evgeniy Polyakov
