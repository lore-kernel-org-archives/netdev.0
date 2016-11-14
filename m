From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy/vitesse: Configure RGMII skew on VSC8601, if
 needed
Date: Mon, 14 Nov 2016 16:18:18 -0500 (EST)
Message-ID: <20161114.161818.1460191406108019273.davem@davemloft.net>
References: <1478993533-1936-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, gokhan@adaptrum.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alex.g@adaptrum.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478993533-1936-1-git-send-email-alex.g@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandru Gagniuc <alex.g@adaptrum.com>
Date: Sat, 12 Nov 2016 15:32:13 -0800

> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
> +		ret = vsc8601_add_skew(phydev);

I think you should use phy_interface_is_rgmii() here.
