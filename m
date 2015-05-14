From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Thu, 14 May 2015 11:34:48 +0800
Message-ID: <20150514033448.GA5080@gondor.apana.org.au>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513054037.GA26595@gondor.apana.org.au>
 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513062038.GA26944@gondor.apana.org.au>
 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57955 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbbENDe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:34:56 -0400
Content-Disposition: inline
In-Reply-To: <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 08:17:43PM -0700, Eric Dumazet wrote:
>
> The initial bug report was on 3.18 for sure.
> 
> (Tester had to leave the program run ~8 hours to get the problem, on a 8
> vCPU VM)
> 
> I can reproduce the bug quite easily (in a few seconds) on 4.0.3, I did
> not spent lot of time trying 3.18, but it seems a bit harder.

No what I'm asking is on 3.18 was it permanent? I can imagine
there being a lookup bug in 3.18 that triggers during a rehash
but I cannot find any permanent corruption issues.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
