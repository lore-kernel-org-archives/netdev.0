From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/9] sfc: Delete unused efx_blinker::led_num field
Date: Fri, 27 Feb 2009 23:07:42 +0000
Message-ID: <1235776062.3164.26.camel@achroite>
References: <1235775847.3164.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:45365 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753043AbZB0XHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 18:07:45 -0500
In-Reply-To: <1235775847.3164.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c     |    1 -
 drivers/net/sfc/net_driver.h |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 6490349..1260875 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -194,7 +194,6 @@ static int sfe4002_init_leds(struct efx_nic *efx)
 	xfp_set_led(efx, SFE4002_RX_LED,
 		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
 	xfp_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
-	efx->board_info.blinker.led_num = SFE4002_FAULT_LED;
 	return 0;
 }
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index eb768fc..ebc7b63 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -385,13 +385,11 @@ struct efx_channel {
 
 /**
  * struct efx_blinker - S/W LED blinking context
- * @led_num: LED ID (board-specific meaning)
  * @state: Current state - on or off
  * @resubmit: Timer resubmission flag
  * @timer: Control timer for blinking
  */
 struct efx_blinker {
-	int led_num;
 	bool state;
 	bool resubmit;
 	struct timer_list timer;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

