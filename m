From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: mediatek: Explicitly include
 linux/interrupt.h
Date: Mon, 24 Jul 2017 13:45:46 -0700 (PDT)
Message-ID: <20170724.134546.1106925176951200316.davem@davemloft.net>
References: <20170720100631.16040-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755734AbdGXUpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:45:47 -0400
In-Reply-To: <20170720100631.16040-1-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Thu, 20 Jul 2017 11:06:31 +0100

> The mediatek ethernet driver uses interrupts but does not explicitly
> include linux/interrupt.h, relying on implicit includes.  Fix this so we
> don't get build breaks as happened for ARM in next-20170720.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied, thanks.
