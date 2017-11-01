From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: marvell: Only configure RGMII delays
 when using RGMII
Date: Wed, 01 Nov 2017 11:26:57 +0900 (KST)
Message-ID: <20171101.112657.673743512067444733.davem@davemloft.net>
References: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aaro.koskinen@iki.fi, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKAC1A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:27:00 -0400
In-Reply-To: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 31 Oct 2017 20:31:28 +0100

> The fix 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> uncovered another bug in the Marvell PHY driver, which broke the
> Marvell OpenRD platform. It relies on the bootloader configuring the
> RGMII delays and does not specify a phy-mode in its device tree.  The
> PHY driver should only configure RGMII delays if the phy mode
> indicates it is using RGMII. Without anything in device tree, the
> mv643xx Ethernet driver defaults to GMII.
> 
> Fixes: 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
