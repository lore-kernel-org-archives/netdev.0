From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6] caif: Remove buggy re-definition of pr_debug
Date: Tue, 21 Sep 2010 22:40:06 +0200
Message-ID: <1285101606-2264-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:47011 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab0IUVkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:40:16 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L940098X6QZXS70@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 22:40:11 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.92]) by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400I0X6QYFY41@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 22:40:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

Remove debugging quirk redefining pr_debug to pr_warning.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---

Hi Dave,
I don't know if this qualify for going to 2.6.36.
It's not really a serious bug, but it would be
nice to get it fixed.

Regards,
Sjur

 net/caif/chnl_net.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 4293e19..73f81b5 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -28,9 +28,6 @@
 #define CONNECT_TIMEOUT (5 * HZ)
 #define CAIF_NET_DEFAULT_QUEUE_LEN 500
=20
-#undef pr_debug
-#define pr_debug pr_warning
-
 /*This list is protected by the rtnl lock. */
 static LIST_HEAD(chnl_net_list);
=20
--=20
1.6.3.3

