From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/11] fix for crash in adummy_init()
Date: Mon, 05 Feb 2007 18:04:47 -0800 (PST)
Message-ID: <20070205.180447.38712391.davem@davemloft.net>
References: <200702060031.l160Vxqf004624@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwalker@mvista.com, chas@cmf.nrl.navy.mil,
	mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965396AbXBFCEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:04:48 -0500
In-Reply-To: <200702060031.l160Vxqf004624@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:30:56 -0800

> From: Daniel Walker <dwalker@mvista.com>
> 
> This was reported by Ingo Molnar here,
> 
> http://lkml.org/lkml/2006/12/18/119
> 
> The problem is that adummy_init() depends on atm_init() , but adummy_init()
> is called first.
> 
> So I put atm_init() into subsys_initcall which seems appropriate, and it
> will still get module_init() if it becomes a module.
> 
> Interesting to note that you could crash your system here if you just load
> the modules in the wrong order.
> 
> Signed-off-by: Daniel Walker <dwalker@mvista.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, and I'll queue this one up for -stable too.

Thanks.
