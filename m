From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Sat, 29 Mar 2008 16:54:15 -0700 (PDT)
Message-ID: <20080329.165415.86797572.davem@davemloft.net>
References: <47E6A5FD.6060407@cosmosbay.com>
	<20080328.183652.99818676.davem@davemloft.net>
	<47EDFB3B.3060206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750830AbYC2XyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 19:54:15 -0400
In-Reply-To: <47EDFB3B.3060206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 29 Mar 2008 09:18:03 +0100

> BTW, can loopback_xmit() be called on an interrupt stack ?

Absolutely, softirq processes TCP data, ACK goes out in
softirq context.

Softirqs run on interrupt stacks just as hardirqs do.
