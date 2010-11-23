From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/3] econet: Move to staging
Date: Tue, 23 Nov 2010 03:52:28 +0000
Message-ID: <1290484348.6770.1329.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39737 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751316Ab0KWDwc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Nov 2010 22:52:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent review has revealed several bugs in obscure protocol
implementations that can be exploited by local users for denial of
service or privilege escalation.

The econet protocol (PF_ECONET) is unmaintained.  There appear to be
no published applications for it, and it has never progressed beyond
'experimental' status.

This protocol generally should not be enabled by distributions, since
the cost of a security flaw affecting all installed systems presumably
outweighs the benefit to the few (if any) legitimate users.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/staging/Kconfig |    2 ++
 net/Kconfig             |    1 -
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index dd94cb2..a9dd984 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -177,5 +177,7 @@ source "drivers/staging/speakup/Kconfig"
 
 source "net/decnet/Kconfig"
 
+source "net/econet/Kconfig"
+
 endif # !STAGING_EXCLUDE_BUILD
 endif # STAGING
diff --git a/net/Kconfig b/net/Kconfig
index 9e4fc29..059c9f1 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -205,7 +205,6 @@ source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
-source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
-- 
1.7.2.3



