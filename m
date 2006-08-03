From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:34:32 +0200
Message-ID: <44D1C328.1030602@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801115102.GA5638@gondor.apana.org.au> <44D1C029.1030300@trash.net> <20060803093013.GA8808@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63227 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932380AbWHCJee
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 05:34:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060803093013.GA8808@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 03, 2006 at 11:21:45AM +0200, Patrick McHardy wrote:
> 
>>This looks OK. But we also need this for the redirect to loopback case,
>>do you want me to put it in dev_gso_segment as well? nfmark and
>>secmark should go in skb_segment I guess?
> 
> 
> OK, you've convinced me.  Let's put them all into skb_segment.
> 
> However, I'd like to have the code shared between skb_segment and
> copy_skb_header so we have only one place to add things to in future.

Yes, that would be good. I'll send a patch later today ..

