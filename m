From: Martin Schwenke <martin@meltin.net>
Subject: [PATCH] net: Document promote_secondaries
Date: Tue, 28 Jan 2014 15:26:42 +1100
Message-ID: <20140128152642.20d94df3@martins.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36061 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455AbaA1E0q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 23:26:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 038a821667f62c496f2bbae27081b1b612122a97 Mon Sep 17 00:00:00 2001
From: Martin Schwenke <martin@meltin.net>
Date: Tue, 28 Jan 2014 15:16:49 +1100
Subject: [PATCH] net: Document promote_secondaries

This option was added a long time ago...

  commit 8f937c6099858eee15fae14009dcbd05177fa91d
  Author: Harald Welte <laforge@gnumonks.org>
  Date:   Sun May 29 20:23:46 2005 -0700

    [IPV4]: Primary and secondary addresses

Signed-off-by: Martin Schwenke <martin@meltin.net>

---
 Documentation/networking/ip-sysctl.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5de0374..ab42c95 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1088,6 +1088,12 @@ igmpv3_unsolicited_report_interval - INTEGER
 	IGMPv3 report retransmit will take place.
 	Default: 1000 (1 seconds)
 
+promote_secondaries - BOOLEAN
+	When a primary IP address is removed from this interface
+	promote a corresponding secondary IP address instead of
+	removing all the corresponding secondary IP addresses.
+
+
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
-- 
1.8.5.3
