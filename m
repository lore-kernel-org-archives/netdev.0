From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 19:43:51 +0200
Message-ID: <1348163031.3440.3.camel@edumazet-glaptop>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
	 <1347901493.26523.151.camel@edumazet-glaptop>
	 <20120917.130732.1894375657044880827.davem@davemloft.net>
	 <1348067659.26523.949.camel@edumazet-glaptop>
	 <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
	 <1348119475.31352.60.camel@edumazet-glaptop>  <505B4E13.5000501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38458 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab2ITRnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 13:43:55 -0400
Received: by bkuw11 with SMTP id w11so382932bku.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 10:43:54 -0700 (PDT)
In-Reply-To: <505B4E13.5000501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 10:10 -0700, Rick Jones wrote:
> On 09/19/2012 10:37 PM, Eric Dumazet wrote:
> > loopback is lossless, so its always surprising we can have TCP
> > retransmits on this medium ;)
> 
> Is it lossless?
> 

It is lossless, yes.

But packets can be dropped by TCP stack for various reasons, including
reordering and retransmits.
