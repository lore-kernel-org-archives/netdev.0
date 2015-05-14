From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 20:17:43 -0700
Message-ID: <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
	 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514025333.GA3853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34578 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbENDRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:17:46 -0400
Received: by pacyx8 with SMTP id yx8so69909649pac.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 20:17:45 -0700 (PDT)
In-Reply-To: <20150514025333.GA3853@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 10:53 +0800, Herbert Xu wrote:
> On Wed, May 13, 2015 at 09:18:04AM -0700, Eric Dumazet wrote:
> >
> > For 4.0.3 I replaced the two rhashtable files by current Linus version,
> > and problem is gone, so the fix is not in net/netlink
> 
> Are you sure the same bug happens in 3.17 too? I can certainly see
> this happening after the dynamic rehashing code went in.
> 
> But in 3.17 it was doing everything under one single lock so I can't
> really see how things can go wrong.

The initial bug report was on 3.18 for sure.

(Tester had to leave the program run ~8 hours to get the problem, on a 8
vCPU VM)

I can reproduce the bug quite easily (in a few seconds) on 4.0.3, I did
not spent lot of time trying 3.18, but it seems a bit harder.
