From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 02/27] drivers/gpio/of: don't use deprecated fields in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:21:59 -0700
Message-ID: <20100311182158.13103.93206.stgit__21242.6521270119$1268332190$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:47893 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab0CKS2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:28:14 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/leds/leds-gpio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/leds/leds-gpio.c b/drivers/leds/leds-gpio.c
index 7ff758a..0e6e9ac 100644
--- a/drivers/leds/leds-gpio.c
+++ b/drivers/leds/leds-gpio.c
@@ -291,8 +291,8 @@ static struct of_platform_driver of_gpio_leds_driver = {
 	.driver = {
 		.name = "of_gpio_leds",
 		.owner = THIS_MODULE,
+		.of_match_table = of_gpio_leds_match,
 	},
-	.match_table = of_gpio_leds_match,
 	.probe = of_gpio_leds_probe,
 	.remove = __devexit_p(of_gpio_leds_remove),
 };

