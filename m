From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Thu, 14 May 2015 10:53:33 +0800
Message-ID: <20150514025333.GA3853@gondor.apana.org.au>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513054037.GA26595@gondor.apana.org.au>
 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513062038.GA26944@gondor.apana.org.au>
 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36380 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933345AbbENCxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 22:53:42 -0400
Content-Disposition: inline
In-Reply-To: <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 09:18:04AM -0700, Eric Dumazet wrote:
>
> For 4.0.3 I replaced the two rhashtable files by current Linus version,
> and problem is gone, so the fix is not in net/netlink

Are you sure the same bug happens in 3.17 too? I can certainly see
this happening after the dynamic rehashing code went in.

But in 3.17 it was doing everything under one single lock so I can't
really see how things can go wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
