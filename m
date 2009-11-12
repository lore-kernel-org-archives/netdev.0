From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [NEXT 1/1] Please pull small fix for ieee802.15.4
Date: Fri, 13 Nov 2009 00:17:15 +0300
Message-ID: <20091112211715.GA13347@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:58060 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbZKLVRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 16:17:18 -0500
Received: by ywh40 with SMTP id 40so716303ywh.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 13:17:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following changes since commit f6d773cd4f3c18c40ab25a5cb92453756237840e:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-next

Dmitry Eremin-Solenikov (1):
      ieee802154: make wpan-phy class registration to subsys_initcall

 net/ieee802154/wpan-class.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 38bac70..2686912 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -205,7 +205,7 @@ err_nl:
 err:
 	return rc;
 }
-module_init(wpan_phy_class_init);
+subsys_initcall(wpan_phy_class_init);
 
 static void __exit wpan_phy_class_exit(void)
 {

-- 
With best wishes
Dmitry

