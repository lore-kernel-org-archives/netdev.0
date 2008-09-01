From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/52] sfc: Change first parameter type of {set,clear}_bit_le() to unsigned
Date: Mon, 1 Sep 2008 12:43:39 +0100
Message-ID: <20080901114338.GV7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34430 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750839AbYIALnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:43:41 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This means the compiler doesn't need to use real division instructions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 219c74a..ab318f7 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -886,13 +886,13 @@ static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
 }
 
 /* Set bit in a little-endian bitfield */
-static inline void set_bit_le(int nr, unsigned char *addr)
+static inline void set_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] |= (1 << (nr % 8));
 }
 
 /* Clear bit in a little-endian bitfield */
-static inline void clear_bit_le(int nr, unsigned char *addr)
+static inline void clear_bit_le(unsigned nr, unsigned char *addr)
 {
 	addr[nr / 8] &= ~(1 << (nr % 8));
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

