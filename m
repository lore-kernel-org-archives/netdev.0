From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] ethtool: fix typo on setting speed 10000
Date: Mon, 07 Jan 2008 09:36:02 -0800
Message-ID: <20080107173602.8429.56354.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29375 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbYAGRgj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 12:36:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

