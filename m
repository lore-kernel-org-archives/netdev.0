From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] ip_tunnel: fix ip tunnel lookup in collect_md
 mode
Date: Tue, 12 Sep 2017 20:45:51 -0700 (PDT)
Message-ID: <20170912.204551.2114618573326791125.davem@davemloft.net>
References: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        pshelar@nicira.com
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdIMDpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:45:53 -0400
In-Reply-To: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 12 Sep 2017 17:47:56 +0800

> In collect_md mode, if the tun dev is down, it still can call
> ip_tunnel_rcv to receive on packets, and the rx statistics increase
> improperly.
> 
> When the md tunnel is down, it's not neccessary to increase RX drops
> for the tunnel device, packets would be recieved on fallback tunnel,
> and the RX drops on fallback device will be increased as expected.
> 
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
