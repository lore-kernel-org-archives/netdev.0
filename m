From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: Add e1000e reg dump support (using e1000 decode
	function)
Date: Thu, 04 Oct 2007 11:37:31 -0700
Message-ID: <20071004183731.31453.3670.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2172 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839AbXJDShd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 14:37:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The e1000 register dump code can print out e1000e register dump
information as well, so enable it for e1000e devices.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 651529e..6c7a2e3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1003,6 +1003,7 @@ static struct {
 	{ "r8169", realtek_dump_regs },
 	{ "de2104x", de2104x_dump_regs },
 	{ "e1000", e1000_dump_regs },
+	{ "e1000e", e1000_dump_regs },
 	{ "igb", igb_dump_regs },
 	{ "ixgb", ixgb_dump_regs },
 	{ "ixgbe", ixgbe_dump_regs },
