From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy/vitesse: Configure RGMII skew on VSC8601,
 if needed
Date: Wed, 16 Nov 2016 17:54:23 -0500 (EST)
Message-ID: <20161116.175423.1067471964290543367.davem@davemloft.net>
References: <20161115.221217.2076182289174952941.davem@davemloft.net>
        <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alex.g@adaptrum.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandru Gagniuc <alex.g@adaptrum.com>
Date: Wed, 16 Nov 2016 01:02:33 -0800

> With RGMII, we need a 1.5 to 2ns skew between clock and data lines. The
> VSC8601 can handle this internally. While the VSC8601 can set more
> fine-grained delays, the standard skew settings work out of the box.
> The same heuristic is used to determine when this skew should be enabled
> as in vsc824x_config_init().
> 
> Tested on custom board with AM3352 SOC and VSC801 PHY.
> 
> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
> ---
> Changes since v1:
>  * Added comment detailing applicability to different RGMII interfaces.

Applied.
