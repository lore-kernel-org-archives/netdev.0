From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mpc52xx: cleanup locking
Date: Tue, 16 Nov 2010 11:39:34 -0800 (PST)
Message-ID: <20101116.113934.232732879.davem@davemloft.net>
References: <1288799798.2511.164.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a.llano@ziv.es, grant.likely@secretlab.ca,
	jhautbois@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756406Ab0KPTjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:39:09 -0500
In-Reply-To: <1288799798.2511.164.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Nov 2010 16:56:38 +0100

> commit 1e4e0767ecb1 (Fix locking on fec_mpc52xx driver) assumed IRQ are
> enabled when an IRQ handler is called.
> 
> It is not the case anymore (IRQF_DISABLED is deprecated), so we can use
> regular spin_lock(), no need for spin_lock_irqsave().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Jean-Michel Hautbois <jhautbois@gmail.com>
> Cc: Asier Llano <a.llano@ziv.es>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Applied, thanks Eric.
