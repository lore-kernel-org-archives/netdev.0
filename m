From: Sebastian Reichel <sre@debian.org>
Subject: [RESEND] [PATCHv2 0/5] wl1251 device tree support
Date: Sat, 15 Feb 2014 00:05:51 +0100
Message-ID: <1392419156-14394-1-git-send-email-sre@debian.org>
References: <20140125000929.GD25488@atomide.com>
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	Sebastian Reichel <sre@debian.org>
To: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>,
	Tony Lindgren <tony@atomide.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ring0.de ([5.45.105.125]:32928 "EHLO smtp.ring0.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbaBNXGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:06:43 -0500
In-Reply-To: <20140125000929.GD25488@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

The following patchset adds device tree support to the spi variant of the
wl1251 driver, which is used in the Nokia N900. Tony requested, that you
take the whole series even if that may introduce merge conflicts:

> Sebastian, please resend the whole series to John and feel free to add my
> acks.  It's best that John picks them all up, otherwise we'll have the same
> issue for v3.15. It seems that we should have just taken the merge conflict
> rather than going back and forth with this.

-- Sebastian

Luciano Coelho (1):
  wl1251: split wl251 platform data to a separate structure

Sebastian Reichel (4):
  wl1251: move power GPIO handling into the driver
  wl1251: spi: add vio regulator support
  wl1251: spi: add device tree support
  Documentation: dt: wireless: Add wl1251

 .../devicetree/bindings/net/wireless/ti,wl1251.txt | 39 ++++++++++++
 arch/arm/mach-omap2/board-omap3pandora.c           |  6 +-
 arch/arm/mach-omap2/board-rx51-peripherals.c       | 13 +---
 drivers/net/wireless/ti/wilink_platform_data.c     | 37 +++++++++--
 drivers/net/wireless/ti/wl1251/sdio.c              | 31 +++++++---
 drivers/net/wireless/ti/wl1251/spi.c               | 71 ++++++++++++++++------
 drivers/net/wireless/ti/wl1251/wl1251.h            |  4 +-
 include/linux/wl12xx.h                             | 24 +++++++-
 8 files changed, 176 insertions(+), 49 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt

-- 
1.8.5.3
