From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix dev_graft_qdisc() locking
Date: Wed, 27 Aug 2008 02:15:09 -0700 (PDT)
Message-ID: <20080827.021509.266949293.davem@davemloft.net>
References: <20080825224854.GA12082@ami.dom.local>
	<E1KXxy1-0000kI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753067AbYH0JPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:15:13 -0400
In-Reply-To: <E1KXxy1-0000kI-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 26 Aug 2008 22:48:13 +1000

> Jarek Poplawski <jarkao2@gmail.com> wrote:
> > pkt_sched: Fix dev_graft_qdisc() locking
> > 
> > During dev_graft_qdisc() dev is deactivated, so qdisc_root_lock()
> > returns wrong lock of noop_qdisc instead of qdisc_sleeping.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Looks good to me!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
