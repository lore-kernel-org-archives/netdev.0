From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.20-rc5] IPV6: skb is unexpectedly freed.
Date: Wed, 24 Jan 2007 15:31:47 +1100
Message-ID: <E1H9ZnX-0001z5-00@gondolin.me.apana.org.au>
References: <45B6C13E.1050204@ncos.nec.co.jp>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mhuth@mvista.com,
	nakagawa.msy@ncos.nec.co.jp
To: nakagawa.msy@ncos.nec.co.jp (Masayuki Nakagawa)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1382 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965653AbXAXEc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 23:32:26 -0500
In-Reply-To: <45B6C13E.1050204@ncos.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp> wrote:
> 
> I suggest to use kfree_skb() instead of __kfree_skb().

I agree.  In fact please do it for all paths in that function, i.e.,
just change __kfree_skb to kfree_skb rather than adding a special case
for this path.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
