From: David Miller <davem@davemloft.net>
Subject: Re: network interface state
Date: Wed, 14 Nov 2007 19:39:49 -0800 (PST)
Message-ID: <20071114.193949.26706514.davem@davemloft.net>
References: <20071114.162201.174150647.davem@davemloft.net>
	<E1IsUCd-0005f4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753159AbXKODju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 22:39:50 -0500
In-Reply-To: <E1IsUCd-0005f4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Nov 2007 10:11:35 +0800

> David Miller <davem@davemloft.net> wrote:
> >
> >> BTW, is it possible to send both these requests out before starting to
> >> read the results?  This would reduce the amount of code quite a bit.
> > 
> > Unfortunately, that won't work.  Like datagram protocols,
> > netlink assumes one message per sendmsg() call.
> 
> Actually netlink packets come with headers so we do allow chaining.
> See netlink_rcv_skb for details.

My bad, you are indeed right.

Ulrich you can therefore send both messages in one go if you
like.
