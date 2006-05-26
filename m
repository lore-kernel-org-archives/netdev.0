From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Fri, 26 May 2006 16:37:27 -0400
Message-ID: <20060526203722.GE32487@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:30732 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751498AbWEZUhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 16:37:42 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 705af309505681f197f81618440954d10f120dc0:
  Martin Schwidefsky:
        s390: fix typo in stop_hz_timer.

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Randy Dunlap:
      wavelan: fix section mismatch
      arlan: fix section mismatch warnings

 drivers/net/wireless/arlan-main.c |    4 ++--
 drivers/net/wireless/wavelan.c    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
index 0e1ac33..bed6823 100644
--- a/drivers/net/wireless/arlan-main.c
+++ b/drivers/net/wireless/arlan-main.c
@@ -1838,7 +1838,7 @@ struct net_device * __init arlan_probe(i
 }
 
 #ifdef  MODULE
-int init_module(void)
+int __init init_module(void)
 {
 	int i = 0;
 
@@ -1860,7 +1860,7 @@ int init_module(void)
 }
 
 
-void cleanup_module(void)
+void __exit cleanup_module(void)
 {
 	int i = 0;
 	struct net_device *dev;
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index ff192e9..dade4b9 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -4306,7 +4306,7 @@ #ifdef	MODULE
  * Insertion of the module
  * I'm now quite proud of the multi-device support.
  */
-int init_module(void)
+int __init init_module(void)
 {
 	int ret = -EIO;		/* Return error if no cards found */
 	int i;
-- 
John W. Linville
linville@tuxdriver.com
