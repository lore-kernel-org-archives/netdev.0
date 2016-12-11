From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] e1000: use disable_hardirq() for e1000_netpoll()
Date: Sat, 10 Dec 2016 23:32:28 -0500 (EST)
Message-ID: <20161210.233228.672613140023674872.davem@davemloft.net>
References: <1481408562-6529-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
        davej@codemonkey.org.uk, peterz@infradead.org,
        jeffrey.t.kirsher@intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbcLKEc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 23:32:29 -0500
In-Reply-To: <1481408562-6529-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 10 Dec 2016 14:22:42 -0800

> In commit 02cea3958664 ("genirq: Provide disable_hardirq()")
> Peter introduced disable_hardirq() for netpoll, but it is forgotten
> to use it for e1000.
> 
> This patch changes disable_irq() to disable_hardirq() for e1000.
> 
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Suggested-by: Sabrina Dubroca <sd@queasysnail.net>
> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
