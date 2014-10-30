From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 2/2] mpls: Allow mpls_gso to be built as module
Date: Thu, 30 Oct 2014 00:50:04 -0700
Message-ID: <1414655404-1572-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:36559 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161430AbaJaBu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 21:50:28 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so6261398pdb.11
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 18:50:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kconfig already allows mpls to be built as module. Following patch
fixes Makefile to do same.

CC: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/mpls/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 0a3c171..6dec088 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -1,4 +1,4 @@
 #
 # Makefile for MPLS.
 #
-obj-y += mpls_gso.o
+obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
-- 
1.7.1
