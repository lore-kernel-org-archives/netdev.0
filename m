From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Sun, 23 Sep 2012 14:27:32 -0400 (EDT)
Message-ID: <20120923.142732.1588718720272601448.davem@davemloft.net>
References: <alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr>
	<20120923.121601.2244503178301624422.davem@davemloft.net>
	<alpine.LNX.2.01.1209231930520.3904@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab2IWS1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2012 14:27:36 -0400
In-Reply-To: <alpine.LNX.2.01.1209231930520.3904@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@inai.de>
Date: Sun, 23 Sep 2012 19:40:33 +0200 (CEST)

> What would a MTU of 64K buy? Offloading seems pointless for the lo
> device. There is no hardware to offload it to - well, the
> machine already has the packet too.

Traversing the stack once instead of N times.
