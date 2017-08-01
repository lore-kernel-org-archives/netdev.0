From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Add dependency on HAS_IOMEM &&
 OF
Date: Mon, 31 Jul 2017 17:54:34 -0700 (PDT)
Message-ID: <20170731.175434.228685948586917728.davem@davemloft.net>
References: <20170801005307.14437-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdHAAyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:54:35 -0400
In-Reply-To: <20170801005307.14437-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 31 Jul 2017 17:53:07 -0700

> The driver needs CONFIG_HAS_IOMEM and OF to be functional, but we still
> let it build with COMPILE_TEST. This fixes the unmet dependency after
> selecting MDIO_BCM_UNIMAC in commit mentioned below:
> 
> warning: (NET_DSA_BCM_SF2 && BCMGENET) selects MDIO_BCM_UNIMAC which has
> unmet direct dependencies (NETDEVICES && MDIO_DEVICE && HAS_IOMEM &&
> OF_MDIO)
> 
> Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC MDIO controller driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
