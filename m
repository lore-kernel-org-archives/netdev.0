From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 5/8] MIPS: BCM63XX: provide enet clocks as "enet" to the ethernet devices
Date: Wed,  2 Aug 2017 11:34:26 +0200
Message-ID: <20170802093429.12572-6-jonas.gorski@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        Kevin Cernekee <cernekee@gmail.com>,
        Jiri Slaby <jslaby@suse.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-arm-kernel@lists.infradead.org,
        linux-serial@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34761 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752826AbdHBJfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 05:35:15 -0400
In-Reply-To: <20170802093429.12572-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add lookups to provide the appropriate enetX clocks as just "enet" to
the ethernet devices.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 arch/mips/bcm63xx/clk.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/mips/bcm63xx/clk.c b/arch/mips/bcm63xx/clk.c
index 0b898e5e4c5b..8a089a92e029 100644
--- a/arch/mips/bcm63xx/clk.c
+++ b/arch/mips/bcm63xx/clk.c
@@ -370,6 +370,8 @@ static struct clk_lookup bcm3368_clks[] = {
 	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
 	CLKDEV_INIT(NULL, "spi", &clk_spi),
 	CLKDEV_INIT(NULL, "pcm", &clk_pcm),
+	CLKDEV_INIT("bcm63xx_enet.0", "enet", &clk_enet0),
+	CLKDEV_INIT("bcm63xx_enet.1", "enet", &clk_enet1),
 };
 
 static struct clk_lookup bcm6328_clks[] = {
@@ -396,6 +398,7 @@ static struct clk_lookup bcm6338_clks[] = {
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
 	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
 	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT("bcm63xx_enet.0", "enet", &clk_enet_misc),
 };
 
 static struct clk_lookup bcm6345_clks[] = {
@@ -409,6 +412,7 @@ static struct clk_lookup bcm6345_clks[] = {
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
 	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
 	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT("bcm63xx_enet.0", "enet", &clk_enet_misc),
 };
 
 static struct clk_lookup bcm6348_clks[] = {
@@ -422,6 +426,8 @@ static struct clk_lookup bcm6348_clks[] = {
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
 	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
 	CLKDEV_INIT(NULL, "spi", &clk_spi),
+	CLKDEV_INIT("bcm63xx_enet.0", "enet", &clk_enet_misc),
+	CLKDEV_INIT("bcm63xx_enet.1", "enet", &clk_enet_misc),
 };
 
 static struct clk_lookup bcm6358_clks[] = {
@@ -437,6 +443,8 @@ static struct clk_lookup bcm6358_clks[] = {
 	CLKDEV_INIT(NULL, "usbd", &clk_usbd),
 	CLKDEV_INIT(NULL, "spi", &clk_spi),
 	CLKDEV_INIT(NULL, "pcm", &clk_pcm),
+	CLKDEV_INIT("bcm63xx_enet.0", "enet", &clk_enet0),
+	CLKDEV_INIT("bcm63xx_enet.1", "enet", &clk_enet1),
 };
 
 static struct clk_lookup bcm6362_clks[] = {
-- 
2.13.2
