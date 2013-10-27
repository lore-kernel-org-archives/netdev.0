From: Sebastian Reichel <sre@debian.org>
Subject: [PATCH 0/4] wl1251 device tree support
Date: Sun, 27 Oct 2013 17:14:25 +0100
Message-ID: <1382890469-25286-1-git-send-email-sre@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, Tony Lindgren <tony@atomide.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Stephen Warren <swarren@wwwdotorg.org>, linux-doc@vger.kernel.org,
 "John W. Linville" <linville@tuxdriver.com>,
 Rob Herring <rob.herring@calxeda.com>, linux-kernel@vger.kernel.org,
 Sachin Kamat <sachin.kamat@linaro.org>, Bill Pemberton <wfp5p@virginia.edu>,
 Sebastian Reichel <sre@debian.org>, Felipe Balbi <balbi@ti.com>,
 Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

The following patchset adds device tree support to
the spi variant of the wl1251 driver.

Some notes:

The first patch is from Luciano's wilink DT support
patchset [0].

The third patch (vio regulator support) is optional. N900's
wifi also worked without this patch, but its probably cleaner
to have it.

The patchset has been tested using DT boot with the Nokia N900
and connecting to my wlan access point.

[0] https://lkml.org/lkml/2013/7/3/333

-- Sebastian

Luciano Coelho (1):
  wl1251: split wl251 platform data to a separate structure

Sebastian Reichel (3):
  wl1251: move power GPIO handling into the driver
  wl1251: spi: add vio regulator support
  wl1251: spi: add device tree support

 .../devicetree/bindings/net/wireless/ti,wl1251.txt | 36 +++++++++++
 arch/arm/mach-omap2/board-omap3pandora.c           |  6 +-
 arch/arm/mach-omap2/board-rx51-peripherals.c       | 15 ++---
 drivers/net/wireless/ti/wilink_platform_data.c     | 37 +++++++++--
 drivers/net/wireless/ti/wl1251/sdio.c              | 31 +++++++---
 drivers/net/wireless/ti/wl1251/spi.c               | 71 ++++++++++++++++------
 drivers/net/wireless/ti/wl1251/wl1251.h            |  4 +-
 include/linux/wl12xx.h                             | 24 +++++++-
 8 files changed, 175 insertions(+), 49 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt

-- 
1.8.4.rc3
