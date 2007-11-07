From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 12/13] SCTP: Clean-up some defines for regressions tests.
Date: Wed,  7 Nov 2007 12:46:30 -0500
Message-ID: <11944575911640-git-send-email-vladislav.yasevich@hp.com>
References: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:51165 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbXKGSJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:09:11 -0500
In-Reply-To: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SCTP regression tests now use the in-kernel version of proc_fs.h
and we don't need to undef any more.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sctp.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 67c997c..34318a3 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -65,7 +65,6 @@
 
 
 #ifdef TEST_FRAME
-#undef CONFIG_PROC_FS
 #undef CONFIG_SCTP_DBG_OBJCNT
 #undef CONFIG_SYSCTL
 #endif /* TEST_FRAME */
-- 
1.5.2.4

