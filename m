From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/20] sfc: Delete unused efx_blinker::led_num field
Date: Thu, 29 Jan 2009 19:21:09 +0000
Message-ID: <1233256869.3656.45.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:47959 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754247AbZA2TVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:21:11 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
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
index 39f1ff8..1f0dc8f 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -394,13 +394,11 @@ struct efx_channel {
 
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

