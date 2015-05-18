From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Tue, 19 May 2015 07:20:03 +0800
Message-ID: <20150518232003.GA26007@gondor.apana.org.au>
References: <20150518200637.GB20709@breakpoint.cc>
 <20150518.162854.1116793790405432801.davem@davemloft.net>
 <20150518204049.GC20709@breakpoint.cc>
 <20150518.165550.359134808190719687.davem@davemloft.net>
 <20150518213329.GA2335@breakpoint.cc>
 <20150518225043.GA25702@gondor.apana.org.au>
 <20150518230255.GB2335@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org, edumazet@google.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50747 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbbERXUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 19:20:11 -0400
Content-Disposition: inline
In-Reply-To: <20150518230255.GB2335@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 01:02:55AM +0200, Florian Westphal wrote:
>
> That would be achived by this patch (perhaps altered to coalesce later
> in ip stack when we're sure skb is locally delivered rather than doing
> it depending on nf_defrag module presence) plus the earlier patches to:

I don't see anything wrong with this particular patch.  If anything
you should extend this patch to also cover IP_DEFRAG_CALL_RA_CHAIN
which AFAICS is not forwarded.

David?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
