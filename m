From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: dev.c: use spin_lock_irqsave() rather than
Date: Mon, 20 Sep 2010 09:14:07 -0700 (PDT)
Message-ID: <20100920.091407.241426689.davem@davemloft.net>
References: <ee14e5e38e7a5df520d902ef8a236bbe9ed206fa.1284991149.git.m.nazarewicz@samsung.com>
	<1284998621.3420.539.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.nazarewicz@samsung.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751786Ab0ITQNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 12:13:48 -0400
In-Reply-To: <1284998621.3420.539.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Sep 2010 18:03:41 +0200

> Hmm, while your patch is technically correct, it seems strange all this
> stuff runs in hard irq context.

I would much rather this RNDIS query response handler get
scheduled to run into softirq context or similar instead.

I am not applying this patch.
