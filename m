From: Guenter Roeck <linux@roeck-us.net>
Subject: Build failure in mainline kernel due to 'lan78xx: add
 ndo_get_stats64'
Date: Sat, 19 Mar 2016 23:55:43 -0700
Message-ID: <20160320065543.GA3951@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Woojung Huh <woojung.huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

your commit a59f8c5b048 ("lan78xx: add ndo_get_stats64") is causing the
following build failure if CONFIG_PM is not enabled.

drivers/net/usb/lan78xx.c: In function 'lan78xx_get_stats64':
drivers/net/usb/lan78xx.c:3274:27: error:
	'struct dev_pm_info' has no member named 'runtime_auto'

Sorry for the noise if this has already been reported.

Guenter
