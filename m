From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: napi_watchdog() can use
 napi_schedule_irqoff()
Date: Tue, 21 Feb 2017 13:28:34 -0500 (EST)
Message-ID: <20170221.132834.613860713986714824.davem@davemloft.net>
References: <1487694056.9415.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752634AbdBUS2g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:28:36 -0500
In-Reply-To: <1487694056.9415.27.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2017 08:20:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> hrtimer handlers run with masked hard IRQ, we can therefore
> use napi_schedule_irqoff()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
