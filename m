From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: emac: fix and unify emac_mdio functions
Date: Thu, 08 Jun 2017 10:47:57 -0400 (EDT)
Message-ID: <20170608.104757.2086799945239662253.davem@davemloft.net>
References: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
        <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
        <dc3b77e7ead819001e09589d1f95eb6c1061f381.1496773338.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivan@de.ibm.com, andrew@lunn.ch
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751672AbdFHOsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:48:03 -0400
In-Reply-To: <dc3b77e7ead819001e09589d1f95eb6c1061f381.1496773338.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Wed,  7 Jun 2017 15:51:16 +0200

> emac_mdio_read_link() was not copying the requested phy settings
> back into the emac driver's own phy api. This has caused a link
> speed mismatch issue for the AR8035 as the emac driver kept
> trying to connect with 10/100MBps on a 1GBit/s link.
> 
> This patch also unifies shared code between emac_setup_aneg()
> and emac_mdio_setup_forced(). And furthermore it removes
> a chunk of emac_mdio_init_phy(), that was copying the same
> data into itself.
> 
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Applied.
