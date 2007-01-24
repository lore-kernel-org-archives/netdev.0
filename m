From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Tue, 23 Jan 2007 22:59:53 -0800 (PST)
Message-ID: <20070123.225953.35016491.davem@davemloft.net>
References: <20070123.221918.35467190.davem@davemloft.net>
	<E1H9c3T-0005HA-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59631
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933178AbXAXG76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:59:58 -0500
In-Reply-To: <E1H9c3T-0005HA-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Jan 2007 17:56:23 +1100

> David Miller <davem@davemloft.net> wrote:
> >
> > Did a complete agreement occur that this patch is ok?
> 
> My only concern is that we're putting an arbitrary list of
> protocols in the generic raw.c.  What's the justification
> for including these protocols in particular but not others?
> 
> Is there any reason why the application can't just use the
> existing IPV6_CHECKSUM socket option to set the same fields?

My understanding in the MH case is that the kernel is going
to make changes to the header that the user can't predict
and thus it's impossible for them to set the correct checksum.

I don't know what the justification is for ICMP6 though :-)

