From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] cpsw: support for control module register
Date: Tue, 24 Sep 2013 10:34:16 -0400 (EDT)
Message-ID: <20130924.103416.2050021711877592417.davem@davemloft.net>
References: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zonque@gmail.com, bcousson@baylibre.com,
	tony@atomide.com, devicetree@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Sat, 21 Sep 2013 00:50:37 +0530

> This patch series adds the support for configuring GMII_SEL register
> of control module to select the phy mode type and also to configure
> the clock source for RMII phy mode whether to use internal clock or
> the external clock from the phy itself.
> 
> Till now CPSW works as this configuration is done in U-Boot and carried
> over to the kernel. But during suspend/resume Control module tends to
> lose its configured value for GMII_SEL register in AM33xx PG1.0, so
> if CPSW is used in RMII or RGMII mode, on resume cpsw is not working
> as GMII_SEL register lost its configuration values.
> 
> The initial version of the patch is done by Daniel Mack but as per
> Tony's comment he wants it as a seperate driver as it is done in USB
> control module. I have created a seperate driver for the same.

Series applied, thanks.
