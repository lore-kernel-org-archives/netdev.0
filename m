From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: bcmgenet: fix uncleaned dma flags
Date: Sun, 23 Aug 2015 23:00:57 -0700 (PDT)
Message-ID: <20150823.230057.178618010826538491.davem@davemloft.net>
References: <1440119306-6789-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, pgynther@google.com, netdev@vger.kernel.org
To: jaedon.shin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbHXGA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 02:00:57 -0400
In-Reply-To: <1440119306-6789-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaedon Shin <jaedon.shin@gmail.com>
Date: Fri, 21 Aug 2015 10:08:26 +0900

> Clean the dma flags of multiq ring buffer int the interface stop
> process. This patch fixes that the genet is not running while the
> interface is re-enabled.
> 
> $ ifup eth0 - running after booting
> $ ifdown eth0
> $ ifup eth0 - not running and occur tx_timeout
> 
> The bcmgenet_dma_disable() in bcmgenet_open() do clean ring16 dma flag
> only. If the genet has multiq, the dma register is not cleaned. and
> bcmgenet_init_dma() is not done correctly. in case
> GENET_V2(tx_queues=4), tdma_ctrl has 0x1e after running
> bcmgenet_dma_disable().
> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>

Applied, thanks.
