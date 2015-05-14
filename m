From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 20:58:10 -0700
Message-ID: <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
	 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514025333.GA3853@gondor.apana.org.au>
	 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514033448.GA5080@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36375 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933746AbbEND6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:58:12 -0400
Received: by iepk2 with SMTP id k2so49112500iep.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 20:58:11 -0700 (PDT)
In-Reply-To: <20150514033448.GA5080@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 11:34 +0800, Herbert Xu wrote:
> On Wed, May 13, 2015 at 08:17:43PM -0700, Eric Dumazet wrote:
> >
> > The initial bug report was on 3.18 for sure.
> > 
> > (Tester had to leave the program run ~8 hours to get the problem, on a 8
> > vCPU VM)
> > 
> > I can reproduce the bug quite easily (in a few seconds) on 4.0.3, I did
> > not spent lot of time trying 3.18, but it seems a bit harder.
> 
> No what I'm asking is on 3.18 was it permanent? I can imagine
> there being a lookup bug in 3.18 that triggers during a rehash
> but I cannot find any permanent corruption issues.

Let me try to reproduce this on 3.18.13. I'll give you an update.
