From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 38/75] iwmc3200top: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:53:20 +0000
Message-ID: <1257630800.15927.436.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Tomas Winkler <tomas.winkler@intel.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42415 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753473AbZKGVxV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:53:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/misc/iwmc3200top/fw-download.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
index 33cb693..2817618 100644
--- a/drivers/misc/iwmc3200top/fw-download.c
+++ b/drivers/misc/iwmc3200top/fw-download.c
@@ -357,3 +357,5 @@ exit:
 
 	return ret;
 }
+
+MODULE_FIRMWARE("iwmc3200top.1.fw");
-- 
1.6.5.2



