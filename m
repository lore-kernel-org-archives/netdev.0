From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH 23/44] includecheck fix: drivers/net, sja1000.c
Date: Wed, 08 Jul 2009 20:42:31 +0530
Message-ID: <1247065951.4382.58.camel@ht.satnam>
References: <1247063308.4382.12.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sam Ravnborg <sam
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53117 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758124AbZGHQDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2009 12:03:15 -0400
In-Reply-To: <1247063308.4382.12.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix the following 'make includecheck' warning:

  drivers/net/can/sja1000/sja1000.c: linux/can/dev.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/can/sja1000/sja1000.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 571f133..08ebee7 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -63,7 +63,6 @@
 #include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
-#include <linux/can/dev.h>
 
 #include "sja1000.h"
 
-- 
1.6.0.6



