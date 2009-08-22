From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to
 tasklet_hrtimer
Date: Sat, 22 Aug 2009 10:41:18 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0908221040450.1769@localhost.localdomain>
References: <20090821.170330.217935645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:51475 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736AbZHVIlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Aug 2009 04:41:25 -0400
In-Reply-To: <20090821.170330.217935645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Aug 2009, David Miller wrote:

> 
> None of this stuff should execute in hw IRQ context, therefore
> use a tasklet_hrtimer so that it runs in softirq context.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Thomas Gleixner <tglx@linutronix.de>

