From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dwc_eth_qos: do not clear pause flags from
 phy_device->supported
Date: Mon, 17 Oct 2016 12:53:53 -0400 (EDT)
Message-ID: <20161017.125353.119289785321107013.davem@davemloft.net>
References: <1476685548-15574-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: larper@axis.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, niklass@axis.com
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476685548-15574-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 17 Oct 2016 08:25:48 +0200

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> phy_device->supported is originally set by the PHY driver.
> The ethernet driver should filter phy_device->supported to only contain
> flags supported by the IP.
> The IP supports setting rx and tx flow control independently,
> therefore SUPPORTED_Pause and SUPPORTED_Asym_Pause should not be cleared.
> If the flags are cleared, pause frames cannot be enabled (even if they
> are supported by the PHY).
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> Signed-off-by: Lars Persson <larper@axis.com>

These two patches do not apply to the current 'net' tree, please respin.
