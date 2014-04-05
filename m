From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 2/2] mac802154: fix duplicate #include headers
Date: Sat,  5 Apr 2014 00:29:01 -0600
Message-ID: <1396679341-23502-3-git-send-email-sakiwit@gmail.com>
References: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43205 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaDEGch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 02:32:37 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so4247091pdj.31
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 23:32:36 -0700 (PDT)
In-Reply-To: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit e6278d92005e ("mac802154: use header operations to
create/parse headers") included the header

		net/ieee802154_netdev.h

which had been included by the commit b70ab2e87f17 ("ieee802154:
enforce consistent endianness in the 802.15.4 stack"). Fix this
duplicate #include by deleting the latter one as the required header
has already been in place.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net
---
 net/mac802154/mib.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 153bd1ddbfbb..f0991f2344d4 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -26,7 +26,6 @@
 #include <net/mac802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
-#include <net/ieee802154_netdev.h>
 
 #include "mac802154.h"
 
