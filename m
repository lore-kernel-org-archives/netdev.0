From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH] ethtool: fix man page for new speeds
Date: Tue, 19 Nov 2013 18:25:40 -0800
Message-ID: <20131120022540.6464.98397.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41454 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211Ab3KTCZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 21:25:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

both the 20000 and 40000 speeds either were wrong or just
not documented.  Fix both.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---
 ethtool.8.in |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index f587ec8..f320f7f 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -549,8 +549,12 @@ lB	l	lB.
 0x020	1000 Full
 0x8000	2500 Full	(not supported by IEEE standards)
 0x1000	10000 Full
-0x20000	20000MLD2 Full	(not supported by IEEE standards)
-0x40000	20000KR2 Full	(not supported by IEEE standards)
+0x200000	20000MLD2 Full	(not supported by IEEE standards)
+0x400000	20000KR2 Full	(not supported by IEEE standards)
+0x800000	40000KR4 Full
+0x1000000	40000CR4 Full
+0x2000000	40000SR4 Full
+0x4000000	40000LR4 Full
 .TE
 .TP
 .BI phyad \ N
