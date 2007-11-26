From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: fix typo on setting speed 10000
Date: Mon, 26 Nov 2007 10:39:06 -0800
Message-ID: <20071126183906.31340.99442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63786 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbXKZSjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 13:39:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

fix the typo in speed 10000 setting.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 3adf843..a668b49 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -524,7 +524,7 @@ static void parse_cmdline(int argc, char **argp)
 					speed_wanted = SPEED_1000;
 				else if (!strcmp(argp[i], "2500"))
 					speed_wanted = SPEED_2500;
-				else if (!strcmp(argp[1], "10000"))
+				else if (!strcmp(argp[i], "10000"))
 					speed_wanted = SPEED_10000;
 				else
 					show_usage(1);
