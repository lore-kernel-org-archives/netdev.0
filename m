From: David Miller <davem@davemloft.net>
Subject: Re: inetpeer with create==0
Date: Thu, 03 Mar 2011 00:34:17 -0800 (PST)
Message-ID: <20110303.003417.35058314.davem@davemloft.net>
References: <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
	<20110302.224220.179921025.davem@davemloft.net>
	<AANLkTinz4ppTi=580K9O=RZ6zbuBrTtjBDhEEnWM3Txg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754261Ab1CCIdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:33:40 -0500
In-Reply-To: <AANLkTinz4ppTi=580K9O=RZ6zbuBrTtjBDhEEnWM3Txg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 3 Mar 2011 16:07:32 +0800

> After routing cache is removed totally, Linux is still unsuitable for
> use as a router on the core internet. Because it isn't a realtime OS,
> and the forwarding delay isn't bounded. With routing cache, the memory
> cost isn't bounded too. :)

With many cores, pipe can be filled no problem, because with multi-core
machine routing lookup proceeds just like Cisco router makes in hardware.

I wrote about this in my blog a few years ago.

