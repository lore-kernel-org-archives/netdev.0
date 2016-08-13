From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] dsa: mv88e6xxx: hide unused functions
Date: Fri, 12 Aug 2016 17:32:47 -0700 (PDT)
Message-ID: <20160812.173247.1281295644746506311.davem@davemloft.net>
References: <20160810215424.1926658-1-arnd@arndb.de>
	<20160810215424.1926658-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160810215424.1926658-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 10 Aug 2016 23:54:08 +0200

> When CONFIG_NET_DSA_HWMON is disabled, we get warnings about two unused
> functions whose only callers are all inside of an #ifdef:
> 
> drivers/net/dsa/mv88e6xxx.c:3257:12: 'mv88e6xxx_mdio_page_write' defined but not used [-Werror=unused-function]
> drivers/net/dsa/mv88e6xxx.c:3244:12: 'mv88e6xxx_mdio_page_read' defined but not used [-Werror=unused-function]
> 
> This adds another ifdef around the function definitions. The warnings
> appeared after the functions were marked 'static', but the problem
> was already there before that.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 57d3231057e9 ("net: dsa: mv88e6xxx: fix style issues")
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
> When I first submitted it on June 23, there was a clash with some
> other patches, this version is based on top of current mainline,
> which contains those patches already, so it should apply cleanly.

Applied, thanks.
