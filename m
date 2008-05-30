From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] sfc: Reduce I2C udelay to 5 resulting in a clock frequency of 100 kHz
Date: Fri, 30 May 2008 22:27:46 +0100
Message-ID: <20080530212745.GH1743@solarflare.com>
References: <cover.1212182201.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jean Delvare <khali@linux-fr.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35692 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753499AbYE3V2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:28:09 -0400
Content-Disposition: inline
In-Reply-To: <cover.1212182201.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8acd53d..8cb5798 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -222,7 +222,7 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
 	.setscl		= falcon_setscl,
 	.getsda		= falcon_getsda,
 	.getscl		= falcon_getscl,
-	.udelay		= 100,
+	.udelay		= 5,
 	/*
 	 * This is the number of system clock ticks after which
 	 * i2c-algo-bit gives up waiting for SCL to become high.
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
