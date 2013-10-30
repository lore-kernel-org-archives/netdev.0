From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Wed, 30 Oct 2013 09:50:02 +0800
Message-ID: <20131030015002.GB1347@gondor.apana.org.au>
References: <20131028115552.GC4408@cpaasch-mac>
 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029144100.GA28046@gondor.apana.org.au>
 <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60171 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751470Ab3J3BuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 21:50:04 -0400
Content-Disposition: inline
In-Reply-To: <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 08:08:13AM -0700, Eric Dumazet wrote:
>
> GRO layer was updated to be able to stack two or three sk_buff,
> fully populated with page frags.
> 
> Thats quite mandatory to support line rate for 40Gb links.

Indeed I missed this.  Which commit introduced this change?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
