From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix of_irq_to_resource() error check
Date: Mon, 31 Jul 2017 17:57:25 -0700 (PDT)
Message-ID: <20170731.175725.2140271815228771192.davem@davemloft.net>
References: <20170729191901.922633706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
        thomas.petazzoni@free-electrons.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdHAA5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:57:25 -0400
In-Reply-To: <20170729191901.922633706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 29 Jul 2017 22:18:41 +0300

> of_irq_to_resource() has recently been  fixed to return negative error #'s
> along with 0 in case of failure,  however the Marvell MV643xx Ethernet
> driver still only regards 0  as invalid IRQ -- fix it up.
> 
> Fixes: 7a4228bbff76 ("of: irq: use of_irq_get() in of_irq_to_resource()")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
