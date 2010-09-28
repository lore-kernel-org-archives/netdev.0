From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 16/17] tg3: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 22:13:02 -0700 (PDT)
Message-ID: <20100927.221302.102545210.davem@davemloft.net>
References: <1285612357.2263.319.camel@achroite.uk.solarflarecom.com>
	<20100927214107.GA32336@mcarlson.broadcom.com>
	<20100927214416.GA32384@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754299Ab0I1FMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 01:12:42 -0400
In-Reply-To: <20100927214416.GA32384@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 27 Sep 2010 14:44:16 -0700

> On Mon, Sep 27, 2010 at 02:41:07PM -0700, Matt Carlson wrote:
>> This should be tp->irq_cnt - 1, not tp->irq_cnt.  The first MSI-X vector
>> only handles link interrupts and device errors.
> 
> I need to correct myself.  If the irq_cnt > 1, then it needs to be
> tp->irq_cnt - 1.  If the irq_cnt == 1, then it should be 1.

I fixed this when I applied Ben's patch, thanks!
