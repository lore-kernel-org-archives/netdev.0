From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 5/8] dsa: Define module author, description,
 license and aliases for drivers
Date: Sat, 26 Nov 2011 00:37:16 +0000
Message-ID: <1322267836.2839.386.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34293 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab1KZAhX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:37:23 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dsa/mv88e6060.c       |    5 +++++
 net/dsa/mv88e6123_61_65.c |    4 ++++
 net/dsa/mv88e6131.c       |    5 +++++
 net/dsa/mv88e6xxx.c       |    4 ++++
 4 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 8f4ff5a..0e028df 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -286,3 +286,8 @@ static void __exit mv88e6060_cleanup(void)
 	unregister_switch_driver(&mv88e6060_switch_driver);
 }
 module_exit(mv88e6060_cleanup);
+
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
+MODULE_DESCRIPTION("Driver for Marvell 88E6060 ethernet switch chip");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:mv88e6060");
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index 7951a6c..6504405 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -432,3 +432,7 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
 };
+
+MODULE_ALIAS("platform:mv88e6123");
+MODULE_ALIAS("platform:mv88e6161");
+MODULE_ALIAS("platform:mv88e6165");
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 45f4123..6786ba4 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -428,3 +428,8 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
 	.get_sset_count		= mv88e6131_get_sset_count,
 };
+
+MODULE_ALIAS("platform:mv88e6085");
+MODULE_ALIAS("platform:mv88e6095");
+MODULE_ALIAS("platform:mv88e6095f");
+MODULE_ALIAS("platform:mv88e6131");
diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index 50fd860..cacd955 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -543,3 +543,7 @@ static void __exit mv88e6xxx_cleanup(void)
 #endif
 }
 module_exit(mv88e6xxx_cleanup);
+
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
+MODULE_DESCRIPTION("Driver for Marvell 88E6XXX ethernet switch chips");
+MODULE_LICENSE("GPL");
-- 
1.7.7.3
