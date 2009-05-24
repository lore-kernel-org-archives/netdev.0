From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [PATCH,RFC] gianfar: fix BUG under load after introduction of skb recycling
Date: Sun, 24 May 2009 17:32:05 +0200
Message-ID: <2A79CAF4-334F-4763-82E3-2460377F3078@it-loops.com>
References: <20090523115143.GB1672@mail.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:36199
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754844AbZEXPcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 11:32:08 -0400
In-Reply-To: <20090523115143.GB1672@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 23, 2009, at 13:51, Lennert Buytenhek wrote:

> Since commit 0fd56bb5be6455d0d42241e65aed057244665e5e ("gianfar:
> Add support for skb recycling"), gianfar puts skbuffs that are in
> the rx ring back onto the recycle list as-is in case there was a
> receive error, but this breaks the following invariant: that all
> skbuffs on the recycle list have skb->data = skb->head + NET_SKB_PAD.
>
>
> Michael, can you re-test with this version of the patch?
> Andy, can you see if this is OK with you?

Hi, I have been running tests with this patch for the last 6 hours and  
had no panics so far.
So it fixes the issues I am seeing as well.

Hope this helps,
Michael
