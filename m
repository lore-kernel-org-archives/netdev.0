From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH net] irda: irlmp_reasons[] can be static
Date: Sat, 20 Apr 2013 11:10:45 +0800
Message-ID: <20130420031045.GC7366@localhost>
References: <5171ea81.dFNn973/RcdmuuQR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32095 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965630Ab3DTDKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 23:10:55 -0400
Content-Disposition: inline
In-Reply-To: <5171ea81.dFNn973/RcdmuuQR%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 irlmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 1064621..98ad6ec 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -58,7 +58,7 @@ int  sysctl_discovery_slots   = 6; /* 6 slots by default */
 int  sysctl_lap_keepalive_time = LM_IDLE_TIMEOUT * 1000 / HZ;
 char sysctl_devname[65];
 
-const char *irlmp_reasons[] = {
+static const char *irlmp_reasons[] = {
 	"ERROR, NOT USED",
 	"LM_USER_REQUEST",
 	"LM_LAP_DISCONNECT",
