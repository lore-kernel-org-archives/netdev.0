From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Wed, 27 May 2015 10:52:00 +0800
Message-ID: <20150527025200.GA21106@gondor.apana.org.au>
References: <20150527000342.GA16379@gondor.apana.org.au>
 <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527013840.GA20585@gondor.apana.org.au>
 <1432692881.4060.333.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42901 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbE0CwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 22:52:06 -0400
Content-Disposition: inline
In-Reply-To: <1432692881.4060.333.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 07:14:41PM -0700, Eric Dumazet wrote:
>
> Fact that Nagle or tso should defer applies in this corner case is not
> very important here, unless you have a specific case in mind ?
> Anyway I double checked and I believes it is fine.

Yes it does appear to be fine on a second look, for the case where
skb->len > mss.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
