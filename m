From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3/3] x25: Move to staging
Date: Tue, 23 Nov 2010 03:55:28 +0000
Message-ID: <1290484528.6770.1336.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>,
	linux-x25@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39750 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017Ab0KWDzh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 22:55:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent review has revealed several bugs in obscure protocol
implementations that can be exploited by local users for denial of
service or privilege escalation.

The x25 protocol (PF_X25) receives only 'odd fixes'.  There appear to
be no published applications for it, and it has never progressed
beyond 'experimental' status.

This protocol generally should not be enabled by distributions, since
the cost of a security flaw affecting all installed systems presumably
outweighs the benefit to the few (if any) legitimate users.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I'm somewhat less sure about this one; maybe it's improving?  But there
is little enough sign of any usefulness after 10 years.

There are several X25 dependencies that presumably should be moved too.

Ben.

 drivers/staging/Kconfig |    2 ++
 net/Kconfig             |    1 -
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index a9dd984..1347242 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -179,5 +179,7 @@ source "net/decnet/Kconfig"
 
 source "net/econet/Kconfig"
 
+source "net/x25/Kconfig"
+
 endif # !STAGING_EXCLUDE_BUILD
 endif # STAGING
diff --git a/net/Kconfig b/net/Kconfig
index 059c9f1..1d396ba 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -203,7 +203,6 @@ source "net/8021q/Kconfig"
 source "net/llc/Kconfig"
 source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
-source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
-- 
1.7.2.3


