From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: of_mdio: fix behavior on missing phy device
Date: Wed, 08 May 2013 13:14:48 -0700 (PDT)
Message-ID: <20130508.131448.594837732354914619.davem@davemloft.net>
References: <1367920171-20264-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367920171-20264-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Tue,  7 May 2013 11:49:31 +0200

> of_mdiobus_register creates a phy_device even if get_phy_device failed
> to create it previously. This causes indefinite polling on non-existent
> PHYs. This fix makes of_mdio_register rely on get_phy_device to
> properly create the device or fail otherwise.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Applied.
