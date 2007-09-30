From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sun, 30 Sep 2007 08:43:41 +0800
Message-ID: <20070930004341.GA7769@gondor.apana.org.au>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3945 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752490AbXI3An5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 20:43:57 -0400
Content-Disposition: inline
In-Reply-To: <20070930002601.GB7502@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 30, 2007 at 08:26:01AM +0800, Herbert Xu wrote:
>
> Indeed.  The only other case I can think of is defragmentation.
> But even there we should be able to squeeze it into the original
> skb :)

OK it won't be pretty but it's definitely doable.  We simply
swap the contents of that skb with the head skb that would've
otherwise been returned.

If this is the only place in netfilter where we need to modify
*pskb then I think it's worthwhile.

So the question is are there any other places that we haven't
covered which also needs to change *pskb?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
