From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 15:20:45 -0700
Message-ID: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	<1347901326.26523.149.camel@edumazet-glaptop>
	<1347901493.26523.151.camel@edumazet-glaptop>
	<20120917.130732.1894375657044880827.davem@davemloft.net>
	<1348067659.26523.949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49103 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab2ISWUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 18:20:46 -0400
Received: by ieak13 with SMTP id k13so2365867iea.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 15:20:45 -0700 (PDT)
In-Reply-To: <1348067659.26523.949.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I did some tests and got no problem so far, even using splice() [ this
> one was tricky because it only deals with order-0 pages at this moment ]
>
> NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4


I applied this patch to net-next and tested with e1000e driver.
With iperf I got around 8 % improvement on loopback.

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>


Vijay
