From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Thu, 14 May 2015 10:55:57 +0800
Message-ID: <20150514025557.GB3853@gondor.apana.org.au>
References: <20150513062038.GA26944@gondor.apana.org.au>
 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513.123520.1301797535605779844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41380 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbENC4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 22:56:03 -0400
Content-Disposition: inline
In-Reply-To: <20150513.123520.1301797535605779844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 12:35:20PM -0400, David Miller wrote:
>
> Alternatively, we could consider reverting the rhashtable conversion
> of netlink in the interim.  It might be the safest solution for
> -stable.

The most suspicous change is the dynamic rehashing, i.e., allowing
insertions/removals during a rehash.  But then Eric says that the
same thing happens under 3.17, where every opertion is under a
single mutex.

So I'm at a loss as to what is wrong and if we can't figure it out
then yes I agree that reverting the netlink rhashtable conversion is
probably the safest option.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
