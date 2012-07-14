From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH] MAINTAINERS: reflect actual changes in IEEE 802.15.4 maintainership
Date: Sat, 14 Jul 2012 10:15:34 +0400
Message-ID: <1342246534-22562-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:63578 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab2GNGPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 02:15:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the life flows, developers priorities shifts a bit. Reflect actual
changes in the maintainership of IEEE 802.15.4 code: Sergey mostly
stopped cared about this piece of code. Most of the work recently was
done by Alexander, so put him to the MAINTAINERS file to reflect his
status and to ease the life of respective patches.

Also add new net/mac802154/ directory to the list of maintained files.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 MAINTAINERS |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 150a29f..f03c703 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3403,13 +3403,14 @@ S:	Supported
 F:	drivers/idle/i7300_idle.c
 
 IEEE 802.15.4 SUBSYSTEM
+M:	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
 M:	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
-M:	Sergey Lapin <slapin@ossfans.org>
 L:	linux-zigbee-devel@lists.sourceforge.net (moderated for non-subscribers)
 W:	http://apps.sourceforge.net/trac/linux-zigbee
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git
 S:	Maintained
 F:	net/ieee802154/
+F:	net/mac802154/
 F:	drivers/ieee802154/
 
 IIO SUBSYSTEM AND DRIVERS
-- 
1.7.10.4
