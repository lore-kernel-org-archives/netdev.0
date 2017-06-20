From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/core: remove explicit do_softirq() from
 busy_poll_stop()
Date: Tue, 20 Jun 2017 13:09:45 -0400 (EDT)
Message-ID: <20170620.130945.326025562609465610.davem@davemloft.net>
References: <20170616172400.10809-1-bigeasy@linutronix.de>
        <20170616172400.10809-2-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, tglx@linutronix.de
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdFTRJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:09:47 -0400
In-Reply-To: <20170616172400.10809-2-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 16 Jun 2017 19:24:00 +0200

> Since commit 217f69743681 ("net: busy-poll: allow preemption in
> sk_busy_loop()") there is an explicit do_softirq() invocation after
> local_bh_enable() has been invoked.
> I don't understand why we need this because local_bh_enable() will
> invoke do_softirq() once the softirq counter reached zero and we have
> softirq-related work pending.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

This indeed is superfluous, applied, thanks.
