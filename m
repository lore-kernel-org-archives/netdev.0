From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 13/16 linux-next] IBM-EMAC: constify of_device_id array
Date: Tue, 17 Mar 2015 19:40:25 +0100
Message-ID: <1426617628-937-4-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617628-937-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:47558 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932564AbbCQSkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 14:40:42 -0400
In-Reply-To: <1426617628-937-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/ibm/emac/core.c  | 2 +-
 drivers/net/ethernet/ibm/emac/mal.c   | 2 +-
 drivers/net/ethernet/ibm/emac/rgmii.c | 2 +-
 drivers/net/ethernet/ibm/emac/tah.c   | 2 +-
 drivers/net/ethernet/ibm/emac/zmii.c  | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 162762d..8a17b97 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2981,7 +2981,7 @@ static int emac_remove(struct platform_device *ofdev)
 }
 
 /* XXX Features in here should be replaced by properties... */
-static struct of_device_id emac_match[] =
+static const struct of_device_id emac_match[] =
 {
 	{
 		.type		= "network",
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index dddaab1..fdb5cdb 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -753,7 +753,7 @@ static int mal_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id mal_platform_match[] =
+static const struct of_device_id mal_platform_match[] =
 {
 	{
 		.compatible	= "ibm,mcmal",
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 457088f..206ccbb 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -305,7 +305,7 @@ static int rgmii_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id rgmii_match[] =
+static const struct of_device_id rgmii_match[] =
 {
 	{
 		.compatible	= "ibm,rgmii",
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index cb18e7f..32cb6c9 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -148,7 +148,7 @@ static int tah_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id tah_match[] =
+static const struct of_device_id tah_match[] =
 {
 	{
 		.compatible	= "ibm,tah",
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index 36409cc..8727b86 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -295,7 +295,7 @@ static int zmii_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id zmii_match[] =
+static const struct of_device_id zmii_match[] =
 {
 	{
 		.compatible	= "ibm,zmii",
-- 
2.1.0
