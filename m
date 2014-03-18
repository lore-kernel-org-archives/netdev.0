From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cpsw: do not register cpts twice
Date: Mon, 17 Mar 2014 22:18:24 -0400 (EDT)
Message-ID: <20140317.221824.1102276673682857159.davem@davemloft.net>
References: <1394984189-1659-1-git-send-email-b.spranger@linutronix.de>
	<1394984189-1659-2-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de, mugunthanvnm@ti.com,
	balbi@ti.com
To: b.spranger@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaCRCSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:18:25 -0400
In-Reply-To: <1394984189-1659-2-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benedikt Spranger <b.spranger@linutronix.de>
Date: Sun, 16 Mar 2014 16:36:29 +0100

> commit f280e89a (drivers: net: cpsw: fix for cpsw crash when build as modules)
> moved cpts_register()/cpts_unregister() to  ndo_open()/ndo_stop(), but failed
> to remove cpts_register in cpsw_probe() which leads to a double registration
> and the following debug object splat.
> 
> [   18.991902] ODEBUG: init active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x2c
> [   19.082249] [<c0059e80>] (init_timer_key) from [<c04965d4>] (cpts_register+0x1f0/0x2c4)
> [   19.090642] [<c04965d4>] (cpts_register) from [<c04931dc>] (cpsw_ndo_open+0x780/0x81c)
> [   19.098948] [<c04931dc>] (cpsw_ndo_open) from [<c0599c2c>] (__dev_open+0xb4/0x118)
> 
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>

Applied, thanks.
