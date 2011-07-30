From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] ipg: Use const
Date: Fri, 29 Jul 2011 19:38:15 -0700
Message-ID: <5311ff3fa329c4551cfdec5960162d3d490509f1.1311993468.git.joe@perches.com>
References: <2ee87bfccbbb5cf1776df6751b65e4a3110019f4.1311993468.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4380 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348Ab1G3CiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 22:38:18 -0400
In-Reply-To: <2ee87bfccbbb5cf1776df6751b65e4a3110019f4.1311993468.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make a couple of declarations const to save some data space.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ipg.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 3aefaad..b470281 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -70,7 +70,7 @@ MODULE_LICENSE("GPL");
  * Variable record -- index by leading revision/length
  * Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
  */
-static unsigned short DefaultPhyParam[] = {
+static const unsigned short DefaultPhyParam[] = {
 	/* 11/12/03 IP1000A v1-3 rev=0x40 */
 	/*--------------------------------------------------------------------------
 	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
@@ -88,7 +88,7 @@ static unsigned short DefaultPhyParam[] = {
 	0x0000
 };
 
-static const char *ipg_brand_name[] = {
+static const char * const ipg_brand_name[] = {
 	"IC PLUS IP1000 1000/100/10 based NIC",
 	"Sundance Technology ST2021 based NIC",
 	"Tamarack Microelectronics TC9020/9021 based NIC",
@@ -1961,7 +1961,7 @@ static void ipg_set_phy_default_param(unsigned char rev,
 {
 	unsigned short length;
 	unsigned char revision;
-	unsigned short *phy_param;
+	const unsigned short *phy_param;
 	unsigned short address, value;
 
 	phy_param = &DefaultPhyParam[0];
-- 
1.7.6.131.g99019

