From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 19:42:21 -0700 (PDT)
Message-ID: <20080325.194221.16658596.davem@davemloft.net>
References: <47E9B115.9060109@windriver.com>
	<47E9B39C.5010502@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yang.shi@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbYCZCm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 22:42:29 -0400
In-Reply-To: <47E9B39C.5010502@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 25 Mar 2008 22:23:24 -0400

> This is bogus -- you should never need to slow down the hot path in such 
> a way.

Slow down in what way?  Even on x86 saving the flags is just
about as expensive as a plain sti/cli.

I would in fact prefer to see drivers unconditionally use
spin_lock_irqsave() et al. in the interrupt handler, for
consistency.
