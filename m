From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Kconfig: Fix PHY infrastructure menu in
 menuconfig
Date: Tue, 19 Sep 2017 13:47:01 -0700 (PDT)
Message-ID: <20170919.134701.886290660323577934.davem@davemloft.net>
References: <20170918125920.10298-1-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, rmk+kernel@arm.linux.org.uk
To: jbrunet@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918125920.10298-1-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jerome Brunet <jbrunet@baylibre.com>
Date: Mon, 18 Sep 2017 14:59:20 +0200

> Since the integration of PHYLINK, the configuration option which
> used to be under the PHY infrastructure menu in menuconfig ended
> up one level up (the network device driver section)
> 
> By placing PHYLINK option right after PHYLIB entry, it broke the
> way Kconfig used to build the menu. See kconfig-language.txt, section
> "Menu structure", 2nd method.
> 
> This is fixed by placing the PHYLINK option just before PHYLIB.
> 
> Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
> Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>

Applied, thank you.
