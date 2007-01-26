From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 20:52:51 +1100
Message-ID: <20070126095251.GA24204@gondor.apana.org.au>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2905 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161019AbXAZJxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 04:53:05 -0500
Content-Disposition: inline
In-Reply-To: <20070126094950.GB1639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 10:49:50AM +0100, Jarek Poplawski wrote:
> 
> How do we know about those improper deals? 
> I understand there should be no other users here
> if it's __kfree_skb now. So I mean to test and warn
> before kfree_skb for some debugging time.

We only need to do that if there is a legitimate reason to use
__kfree_skb.  Which there was when this code was first written
since kfree_skb had an unconditional atomic op back then.

Now that it's a conditinoal atomic op __kfree_skb is no longer
necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
