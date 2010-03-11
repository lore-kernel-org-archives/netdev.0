From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 2/3] net: tcp: make veno selectable as default congestion module
Date: Thu, 11 Mar 2010 20:57:28 +0100
Message-ID: <1268337450-6749-3-git-send-email-jengelh@medozas.de>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56845 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932Ab0CKT5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 14:57:36 -0500
In-Reply-To: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/Kconfig |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 731c47b..c9a1c68 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -593,6 +593,9 @@ choice
 	config DEFAULT_VEGAS
 		bool "Vegas" if TCP_CONG_VEGAS=y
 
+	config DEFAULT_VENO
+		bool "Veno" if TCP_CONG_VENO=y
+
 	config DEFAULT_WESTWOOD
 		bool "Westwood" if TCP_CONG_WESTWOOD=y
 
@@ -616,6 +619,7 @@ config DEFAULT_TCP_CONG
 	default "hybla" if DEFAULT_HYBLA
 	default "vegas" if DEFAULT_VEGAS
 	default "westwood" if DEFAULT_WESTWOOD
+	default "veno" if DEFAULT_VENO
 	default "reno" if DEFAULT_RENO
 	default "cubic"
 
-- 
1.7.0

