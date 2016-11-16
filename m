From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcm63xx_enet: fix build failure
Date: Wed, 16 Nov 2016 17:51:54 -0500 (EST)
Message-ID: <20161116.175154.767887282639567610.davem@davemloft.net>
References: <1479336616-26500-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: sudipm.mukherjee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753215AbcKPWv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:51:58 -0500
In-Reply-To: <1479336616-26500-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Wed, 16 Nov 2016 22:50:16 +0000

> The build of mips bcm63xx_defconfig was failing with the error:
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:1440:2:
> 	error: expected expression before 'return'
> 
> The return statement should be termibated with ';' and not ','.
> 
> Fixes: 42469bf5d9bb ("net: bcm63xx_enet: Utilize phy_ethtool_nway_reset")
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Already fixes in the current net-next tree.
