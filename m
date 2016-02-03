From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 16/16] batman-adv: Switch to HTTPS version of links
Date: Wed,  3 Feb 2016 10:18:37 +0800
Message-ID: <1454465917-13332-17-git-send-email-a__13324.6322664947$1454467238$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:9705 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcBCCkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:23 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

open-mesh.org and its subdomains can only be accessed via HTTPS. HTTP-only
requests are currently redirected automatically to HTTPS but references in
the source code should be only https.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 Documentation/networking/batman-adv.txt | 2 +-
 MAINTAINERS                             | 2 +-
 net/batman-adv/Kconfig                  | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index ff23b755f5e4..1b5e7a7f2185 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -187,7 +187,7 @@ interfaces to the kernel module settings.
 
 For more information, please see the manpage (man batctl).
 
-batctl is available on http://www.open-mesh.org/
+batctl is available on https://www.open-mesh.org/
 
 
 CONTACT
diff --git a/MAINTAINERS b/MAINTAINERS
index f678c37107f5..1e216aa4d25c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2147,7 +2147,7 @@ M:	Marek Lindner <mareklindner@neomailbox.ch>
 M:	Simon Wunderlich <sw@simonwunderlich.de>
 M:	Antonio Quartulli <a@unstable.cc>
 L:	b.a.t.m.a.n@lists.open-mesh.org
-W:	http://www.open-mesh.org/
+W:	https://www.open-mesh.org/
 S:	Maintained
 F:	net/batman-adv/
 
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index c6fc8f756c9a..2dd40e5ea030 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -12,7 +12,7 @@ config BATMAN_ADV
           B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
           a routing protocol for multi-hop ad-hoc mesh networks. The
           networks may be wired or wireless. See
-          http://www.open-mesh.org/ for more information and user space
+          https://www.open-mesh.org/ for more information and user space
           tools.
 
 config BATMAN_ADV_BLA
-- 
2.7.0
