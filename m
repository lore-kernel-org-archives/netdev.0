From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH 9/9] ipv6: sr: add documentation file for per-interface sysctls
Date: Mon, 17 Oct 2016 16:43:42 +0200
Message-ID: <1476715422-19151-5-git-send-email-david.lebrun@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34208 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755224AbcJQOvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:51:35 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id 63D9067DB63
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:42:07 +0200 (CEST)
In-Reply-To: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for some SR-related per-interface
sysctls.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 Documentation/networking/seg6-sysctl.txt | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)
 create mode 100644 Documentation/networking/seg6-sysctl.txt

diff --git a/Documentation/networking/seg6-sysctl.txt b/Documentation/networking/seg6-sysctl.txt
new file mode 100644
index 0000000..bdbde23
--- /dev/null
+++ b/Documentation/networking/seg6-sysctl.txt
@@ -0,0 +1,18 @@
+/proc/sys/net/conf/<iface>/seg6_* variables:
+
+seg6_enabled - BOOL
+	Accept or drop SR-enabled IPv6 packets on this interface.
+
+	Relevant packets are those with SRH present and DA = local.
+
+	0 - disabled (default)
+	not 0 - enabled
+
+seg6_require_hmac - INTEGER
+	Define HMAC policy for ingress SR-enabled packets on this interface.
+
+	-1 - Ignore HMAC field
+	0 - Accept SR packets without HMAC, validate SR packets with HMAC
+	1 - Drop SR packets without HMAC, validate SR packets with HMAC
+
+	Default is 0.
-- 
2.7.3
