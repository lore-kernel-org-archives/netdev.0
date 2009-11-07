From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 42/75] myri10ge: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:54:44 +0000
Message-ID: <1257630884.15927.442.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Gallatin <gallatin@myri.com>, Brice Goglin <brice@myri.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53564 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753251AbZKGVyq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:54:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 5319db9..85e1b6a 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -263,6 +263,10 @@ static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
 static char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
 static char *myri10ge_fw_rss_unaligned = "myri10ge_rss_ethp_z8e.dat";
 static char *myri10ge_fw_rss_aligned = "myri10ge_rss_eth_z8e.dat";
+MODULE_FIRMWARE("myri10ge_ethp_z8e.dat");
+MODULE_FIRMWARE("myri10ge_eth_z8e.dat");
+MODULE_FIRMWARE("myri10ge_rss_ethp_z8e.dat");
+MODULE_FIRMWARE("myri10ge_rss_eth_z8e.dat");
 
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
-- 
1.6.5.2



