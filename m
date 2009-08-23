From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to
 tasklet_hrtimer
Date: Sat, 22 Aug 2009 18:08:45 -0700 (PDT)
Message-ID: <20090822.180845.245863939.davem@davemloft.net>
References: <20090821.170330.217935645.davem@davemloft.net>
	<alpine.LFD.2.00.0908221040450.1769@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933414AbZHWBIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 21:08:32 -0400
In-Reply-To: <alpine.LFD.2.00.0908221040450.1769@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sat, 22 Aug 2009 10:41:18 +0200 (CEST)

> On Fri, 21 Aug 2009, David Miller wrote:
> 
>> 
>> None of this stuff should execute in hw IRQ context, therefore
>> use a tasklet_hrtimer so that it runs in softirq context.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Thomas Gleixner <tglx@linutronix.de>

Thanks for reviewing.
