From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 2/8] MIPS: BCM63XX: provide periph clock as refclk for uart
Date: Wed,  2 Aug 2017 11:34:23 +0200
Message-ID: <20170802093429.12572-3-jonas.gorski@gmail.com>
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
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34813 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbdHBJfL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 05:35:11 -0400
In-Reply-To: <20170802093429.12572-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a lookup as "refclk" to describe its function for the uarts.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 arch/mips/bcm63xx/clk.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/mips/bcm63xx/clk.c b/arch/mips/bcm63xx/clk.c
index eb1cb0bf930b..0b898e5e4c5b 100644
--- a/arch/mips/bcm63xx/clk.c
+++ b/arch/mips/bcm63xx/clk.c
@@ -360,6 +360,8 @@ EXPORT_SYMBOL_GPL(clk_round_rate);
 static struct clk_lookup bcm3368_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.1", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
 	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
@@ -373,6 +375,8 @@ static struct clk_lookup bcm3368_clks[] = {
 static struct clk_lookup bcm6328_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.1", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
@@ -384,6 +388,7 @@ static struct clk_lookup bcm6328_clks[] = {
 static struct clk_lookup bcm6338_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
 	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
@@ -396,6 +401,7 @@ static struct clk_lookup bcm6338_clks[] = {
 static struct clk_lookup bcm6345_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
 	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
@@ -408,6 +414,7 @@ static struct clk_lookup bcm6345_clks[] = {
 static struct clk_lookup bcm6348_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
 	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
@@ -420,6 +427,8 @@ static struct clk_lookup bcm6348_clks[] = {
 static struct clk_lookup bcm6358_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.1", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enet0", &clk_enet0),
 	CLKDEV_INIT(NULL, "enet1", &clk_enet1),
@@ -433,6 +442,8 @@ static struct clk_lookup bcm6358_clks[] = {
 static struct clk_lookup bcm6362_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.1", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
@@ -446,6 +457,8 @@ static struct clk_lookup bcm6362_clks[] = {
 static struct clk_lookup bcm6368_clks[] = {
 	/* fixed rate clocks */
 	CLKDEV_INIT(NULL, "periph", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.0", "refclk", &clk_periph),
+	CLKDEV_INIT("bcm63xx_uart.1", "refclk", &clk_periph),
 	/* gated clocks */
 	CLKDEV_INIT(NULL, "enetsw", &clk_enetsw),
 	CLKDEV_INIT(NULL, "usbh", &clk_usbh),
-- 
2.13.2
