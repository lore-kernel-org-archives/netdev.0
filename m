From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c515: Write outside array bounds
Date: Thu, 30 Jul 2009 13:28:35 -0700 (PDT)
Message-ID: <20090730.132835.35513402.davem@davemloft.net>
References: <4A705904.4020505@gmail.com>
	<20090729204300.GC3058@ami.dom.local>
	<4A717558.2050407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750997AbZG3U22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:28:28 -0400
In-Reply-To: <4A717558.2050407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 30 Jul 2009 12:26:32 +0200

> if dev_alloc_skb() fails on the first iteration, a write to
> cp->rx_ring[-1] occurs.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
