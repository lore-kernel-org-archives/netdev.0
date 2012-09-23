From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Sun, 23 Sep 2012 14:47:28 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr>
References: <505B773E.9070501@hp.com> <1348172722.2669.10.camel@edumazet-glaptop> <1348242511.2669.635.camel@edumazet-glaptop> <20120921.122705.1344923255084267186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:46307 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095Ab2IWMra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 08:47:30 -0400
In-Reply-To: <20120921.122705.1344923255084267186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2012-09-21 18:27, David Miller wrote:

>From: Eric Dumazet <eric.dumazet@gmail.com>
>Date: Fri, 21 Sep 2012 17:48:31 +0200
>
>> There is probably a reason why lo default MTU is 16436 ?
>
>That's what fit into L1 caches back in 1999

Would it make sense to automatically set lo's MTU on device registration 
to the actual size of the L1 that the $running system has?
