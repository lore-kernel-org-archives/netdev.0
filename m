From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [Xen-devel] Re: Xen netfront fixes for changed skbuff in	net-2.6.22.git
Date: Wed, 28 Mar 2007 14:55:56 -0700
Message-ID: <460AE46C.9050805@goop.org>
References: <460AB5A1.1000807@goop.org> <20070328214604.GA10231@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>,
	NetDev <netdev@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:38211 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933305AbXC1Vzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 17:55:52 -0400
In-Reply-To: <20070328214604.GA10231@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> I've had a look at now and you can just stuff it into one of the other
> pointers that's still there.  We just need to make sure that it is
> reset properly before we feed the packet into the stack.  The pointer
> skb->dev is one candidate but there are plenty of others.
>   

Hm, I was wondering if there's a nicer way of getting the same result. 
Does it need to be done that way?

Thanks,
    J
