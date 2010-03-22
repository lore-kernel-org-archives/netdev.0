From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sun, 21 Mar 2010 20:12:58 -0700 (PDT)
Message-ID: <20100321.201258.184825751.davem@davemloft.net>
References: <20100322013257.GA14080@gondor.apana.org.au>
	<20100321.183656.173864141.davem@davemloft.net>
	<20100322014010.GA14182@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753711Ab0CVDMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:12:35 -0400
In-Reply-To: <20100322014010.GA14182@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 22 Mar 2010 09:40:10 +0800

> On Sun, Mar 21, 2010 at 06:36:56PM -0700, David Miller wrote:
>>
>> And as a consequence, making the xfrm_dst's be per-cpu would mess with
>> route metrics for TCP.
> 
> Actually xfrm_dst currently relies on IPv4 rt objects to maintain
> the metrics.  So as long as IPv4 routes are still global, then the
> metrics won't be affected as far as can I see.
> 
> Did I miss something?

Good point, I was misunderstanding how things work now and how
that would change with your proposal.

Having multiple xfrm_dsts exist for an IPSEC route seems fine
to me.
