From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Initialize mdio clock at probe function
Date: Thu, 09 Feb 2017 17:10:40 -0500 (EST)
Message-ID: <20170209.171040.432452627006517540.davem@davemloft.net>
References: <1486592066-9097-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        yendapally.reddy@broadcom.com
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486592066-9097-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Wed,  8 Feb 2017 17:14:26 -0500

> From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
> 
> USB PHYs need the MDIO clock divisor enabled earlier to work.
> Initialize mdio clock divisor in probe function. The ext bus
> bit available in the same register will be used by mdio mux
> to enable external mdio.
> 
> Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
> Fixes: ddc24ae1 ("net: phy: Broadcom iProc MDIO bus driver")
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Applied.
