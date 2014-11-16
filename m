From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH] ip-link: Document IPoIB link type in the man page
Date: Sun, 16 Nov 2014 09:43:34 +0200
Message-ID: <1416123814-20672-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Haggai Eran <haggaie@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41492 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751656AbaKPHnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2014 02:43:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation on how to create devices of type IP-over-Infiniband
in the man page.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 man/man8/ip-link.8.in |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 6d32f5e..a05633f 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -449,6 +449,23 @@ when tunneling non-IP packets. The default value is 00.
 
 .in -8
 
+.TP
+IPoIB Type Support
+For a link of type
+.I IPoIB
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE " name " NAME
+.BI type " ipoib [ " pkey " PKEY ] [" mode " MODE " ]
+
+.in +8
+.sp
+.BI  pkey " PKEY "
+- specifies the IB P-Key to use.
+
+.BI  mode " MODE "
+- specifies the mode (datagram or connected) to use.
+
 .SS ip link delete - delete virtual link
 .I DEVICE
 specifies the virtual  device to act operate on.
-- 
1.7.1
