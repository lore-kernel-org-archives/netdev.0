From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 19:17:14 -0700
Message-ID: <1432693034.4060.336.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150527000342.GA16379@gondor.apana.org.au>
	 <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527013840.GA20585@gondor.apana.org.au>
	 <20150527020129.GA20792@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34051 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbE0CRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 22:17:17 -0400
Received: by ieczm2 with SMTP id zm2so3495832iec.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 19:17:16 -0700 (PDT)
In-Reply-To: <20150527020129.GA20792@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 10:01 +0800, Herbert Xu wrote:
> On Wed, May 27, 2015 at 09:38:40AM +0800, Herbert Xu wrote:
> > 
> > Not really.  They're not identical.  For example, before your
> > patch a packet greater than MSS with TSO disabled would call
> > tcp_nagle_test, with your patch it will call tcp_tso_should_defer
> > instead.
> > 
> > Maybe this is OK but it is far from obvious.
> 
> Funny enough it was you who originally introduced this change
> in behaviour:
> 
> commit 8f26fb1c1ed81c33f5d87c5936f4d9d1b4118918
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Oct 15 12:24:54 2013 -0700
> 
>     tcp: remove the sk_can_gso() check from tcp_set_skb_tso_segs()
> 
> Now you're trying to do it again :)
> 
> The problem is back at the very beginning, tso_segs > 1 was the
> same as TSO enabled.  So we either need to restore this identity
> or find a new way of indiciating that TSO is enabled.
> 
> Cheers,


I have no idea of what you are trying to tell me.

I want to remove duplicate tests, not pushing new ones.

I do not want to add back sk_can_gso()

I do not find something funny here. Sorry.
