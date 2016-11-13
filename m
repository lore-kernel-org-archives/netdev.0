From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/11] amd-xgbe: AMD XGBE driver updates
 2016-11-10
Date: Sun, 13 Nov 2016 00:56:47 -0500 (EST)
Message-ID: <20161113.005647.1758389589577228475.davem@davemloft.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbcKMF4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 00:56:49 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 10 Nov 2016 17:09:17 -0600

> This patch series is targeted at adding support for a new PCI version
> of the hardware. As part of the new PCI device, there is a new PCS/PHY
> interaction, ECC support, I2C sideband communication, SFP+ support and
> more.
> 
> The following updates and fixes are included in this driver update series:
> 
> - Hardware workaround for possible incorrectly generated interrupts
>   during software reset
> - Hardware workaround for Tx timestamp register access order
> - Add support for a PCI version of the device
> - Increase the Rx queue limit to take advantage of the increased number
>   of DMA channels that might be available
> - Add support for a new DMA channel interrupt mode
> - Add ECC support for the device memory
> - Add support for using the integrated I2C controller for sideband
>   communication
> - Expose the phylib phy_aneg_done() function so it can be called by the
>   driver
> - Add support for SFP+ modules
> - Add support for MDIO attached PHYs
> - Add support for KR re-driver between the PCS/SerDes and an external
>   PHY
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
