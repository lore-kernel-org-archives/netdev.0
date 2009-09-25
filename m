From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] skb align patch
Date: Fri, 25 Sep 2009 15:18:35 -0700
Message-ID: <20090925221835.GA3975@gondor.apana.org.au>
References: <20090923054748.GA24045@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, shemminger@vyatta.com,
	jesse.brandeburg@gmail.com, hawk@diku.dk, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55070 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752837AbZIYWSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:18:49 -0400
Content-Disposition: inline
In-Reply-To: <20090923054748.GA24045@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@infradead.org> wrote:
>
> As I pointed out to Herbert already, this alignment change may actually
> make things worse or even break things as long as compare_ether_header()
> used in __napi_gro_receive() expects the IP header to be aligned to 4
> bytes. That can be fixed of course, just wanted to mention it.

Well this particular patch doesn't because x86-64 is fine with
unaligned access :)

But yeah we need to fix up GRO to not do that for other arches.
It's on my list.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
