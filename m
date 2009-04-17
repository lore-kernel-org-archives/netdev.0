From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 02:33:57 -0700 (PDT)
Message-ID: <20090417.023357.121366056.davem@davemloft.net>
References: <20090417110703.781f8a0e@hskinnemoen-d830>
	<20090417.020841.21679845.davem@davemloft.net>
	<20090417112553.21e1f2e5@hskinnemoen-d830>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760382AbZDQJeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:34:06 -0400
In-Reply-To: <20090417112553.21e1f2e5@hskinnemoen-d830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Fri, 17 Apr 2009 11:25:53 +0200

> I guess you're right -- we just have to be careful about calling
> printk() from within the driver. But it seems a lot easier to just drop
> the lock before dumping an error message than it is to work around that
> disable_irq() deadlock. And if you're running with verbose debugging
> enabled, you probably shouldn't be using netconsole anyway.

Therefore, do you agree to add Thomas's patch as-is?

If so please provide an Acked-by:
