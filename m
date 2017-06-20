From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net-next: mediatek: various performance
 improvements
Date: Tue, 20 Jun 2017 13:40:52 -0400 (EDT)
Message-ID: <20170620.134052.264394808259657804.davem@davemloft.net>
References: <20170619133706.3415-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sean.wang@mediatek.com, linux-mediatek@lists.infradead.org,
        netdev@vger.kernel.org
To: john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdFTRky (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:40:54 -0400
In-Reply-To: <20170619133706.3415-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <john@phrozen.org>
Date: Mon, 19 Jun 2017 15:37:02 +0200

> During development we mainly ran testing using iperf doing 1500 byte
> tcp frames. It was pointed out recently, that the driver does not perform
> very well when using 512 byte udp frames. The biggest problem was that
> RPS was not working as no rx queue was being set. fixing this more than
> doubled the throughput. Additionally the IRQ mask register is now locked
> independently for RX and TX. RX IRQ aggregation is also added. With all
> these patches applied we can almost triple the throughput.
> 
> While at it we also add PHY status change reporting for GMACs connecting
> directly to a PHY.

Series applied, thank you.
