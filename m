From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix TX queue overflow in trapped mode
Date: Sat, 28 Apr 2007 20:59:00 -0700 (PDT)
Message-ID: <20070428.205900.35468970.davem@davemloft.net>
References: <200704282212.32443.sshtylyov@ru.mvista.com>
	<200704282252.01296.sshtylyov@ru.mvista.com>
	<200704290025.41760.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754496AbXD2D6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 23:58:52 -0400
In-Reply-To: <200704290025.41760.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Sun, 29 Apr 2007 00:25:41 +0400

> On Saturday 28 April 2007 22:52, I wrote:
> 
> > > CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely
> > > bypassed in the netpoll's "trapped" mode which easily causes overflows in
> > > the drivers with short TX queues (most notably, in 8139too with its
> > > 4-deep queue).  So, make this option more sensible by making it only
> > > bypass the TX softirq wakeup.
> >    Dammit!  Finally forgot to add acks earned so far:
> 
>    Oh, and there was even another one:
> 
> > > Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> > Acked-by: Jeff Garzik <jgarzik@pobox.com>
> Acked-by: Tom Rini <trini@kernel.crashing.org>
> > Acked-by: Matt Mackall <mpm@selenic.com>

Applied, I'll push this to -stable too.
