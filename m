From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] of: of_mdio: Ensure mdio device is a PHY
Date: Thu, 28 Jan 2016 16:08:24 -0800 (PST)
Message-ID: <20160128.160824.1353384794421241954.davem@davemloft.net>
References: <1453817550-4770-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	aaro.koskinen@nokia.com, olof@lixom.net
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbcA2AIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:08:25 -0500
In-Reply-To: <1453817550-4770-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 26 Jan 2016 15:12:30 +0100

> of_phy_find_device() is used to find the phy device associated with a
> device node. It is expected the node is for a PHY device, but in fact
> it could of been probed as a generic MDIO device. Ensure the device is
> a PHY before returning it.
> 
> Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
