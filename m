From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPV6] Defer IPv6 device initialization until a valid qdisc is specified
Date: Wed, 10 Oct 2007 11:27:22 +0800
Message-ID: <E1IfSEE-0006z9-00@gondolin.me.apana.org.au>
References: <20071010.121642.107601594.yoshfuji@linux-ipv6.org>
Cc: herbert@gondor.apana.org.au, mitch@linux.vnet.ibm.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????????????)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2965 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750752AbXJJD1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 23:27:31 -0400
In-Reply-To: <20071010.121642.107601594.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org> wrote:
> 
> We'd really like to do our best to avoid such random failures
> even if it may/can not be perfect.

OK I see your point of view but there's got to be a better way
than this.

As it is your tests will fail randomly anyway if you do it in
virtual guest because the carrier is always on since the switch
in that case is the host OS.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
