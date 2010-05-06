From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/gianfar: drop recycled skbs on MTU change
Date: Thu, 06 May 2010 00:26:04 -0700 (PDT)
Message-ID: <20100506.002604.58437083.davem@davemloft.net>
References: <20100505.005704.115933493.davem@davemloft.net>
	<20100505083047.GA4398@Chamillionaire.breakpoint.cc>
	<C4C9C232-1DA6-43BE-A9FF-4A591E3FF672@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian@breakpoint.cc, afleming@gmail.com, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57068
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755377Ab0EFHZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:25:57 -0400
In-Reply-To: <C4C9C232-1DA6-43BE-A9FF-4A591E3FF672@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 5 May 2010 10:18:40 -0500

> 
> On May 5, 2010, at 3:30 AM, Sebastian Andrzej Siewior wrote:
> 
>> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>> 
>> The size for skbs which is added to the recycled list is using the
>> current descriptor size which is current MTU. gfar_new_skb() is also
>> using this size. So after changing or alteast increasing the MTU all
>> recycled skbs should be dropped.
>> 
>> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
 ...
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied, thanks everyone.
