From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Fri, 15 May 2015 08:06:48 +0800
Message-ID: <20150515000647.GA13821@gondor.apana.org.au>
References: <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
 <1431614276.27831.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40988 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423125AbbEOAG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 20:06:57 -0400
Content-Disposition: inline
In-Reply-To: <1431614276.27831.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 07:37:56AM -0700, Eric Dumazet wrote:
>
> This solves the corruption thanks Herbert.

Great.

> But wasn't rhashtable meant to be faster ? ;)

Is it, that's news to me :)

> Current tree is still slower than 3.15 :(
> 
> $ ./getaddrinfo_many.sh 
> TPS: 123152.70936  Seconds Elapsed: 0  Current time: Thu May 14 07:36:52 PDT 2015
> TPS: 123304.562269  Seconds Elapsed: 1  Current time: Thu May 14 07:36:53 PDT 2015
> TPS: 123915.737299  Seconds Elapsed: 2  Current time: Thu May 14 07:36:54 PDT 2015
> TPS: 123456.790123  Seconds Elapsed: 3  Current time: Thu May 14 07:36:55 PDT 2015
> TPS: 124843.945069  Seconds Elapsed: 4  Current time: Thu May 14 07:36:56 PDT 2015
> TPS: 122850.12285  Seconds Elapsed: 4  Current time: Thu May 14 07:36:56 PDT 2015
> TPS: 123001.230012  Seconds Elapsed: 5  Current time: Thu May 14 07:36:57 PDT 2015
> TPS: 123001.230012  Seconds Elapsed: 6  Current time: Thu May 14 07:36:58 PDT 2015
> TPS: 122549.019608  Seconds Elapsed: 7  Current time: Thu May 14 07:36:59 PDT 2015
> TPS: 123762.376238  Seconds Elapsed: 8  Current time: Thu May 14 07:37:00 PDT 2015
> TPS: 123304.562269  Seconds Elapsed: 9  Current time: Thu May 14 07:37:01 PDT 2015
> TPS: 123152.70936  Seconds Elapsed: 9  Current time: Thu May 14 07:37:01 PDT 2015
> TPS: 123001.230012  Seconds Elapsed: 10  Current time: Thu May 14 07:37:02 PDT 2015

OK I'll try to see if we can make this faster.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
