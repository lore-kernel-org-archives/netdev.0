From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2011-03-15
Date: Tue, 15 Mar 2011 20:12:34 -0400
Message-ID: <20110316001234.GA28663@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

I nearly forgot this one!  It is a really simple patch to enable the use
of some (so far still unreleased) firmware for the iwl1000 hardware.

Please pull for 2.6.39-rc1, so that users will be able to use the
new firmware when it is generally available!

John

---

The following changes since commit 84c0c6933cb0303fa006992a6659c2b46de4eb17:

  smsc911x: Fix build error when SMSC_TRACE() used (2011-03-15 14:52:48 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Fry, Donald H (1):
      iwlagn: Support new 1000 microcode.

 drivers/net/wireless/iwlwifi/iwl-1000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index ba78bc8..507cab4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -49,7 +49,7 @@
 #include "iwl-agn-debugfs.h"
 
 /* Highest firmware API version supported */
-#define IWL1000_UCODE_API_MAX 3
+#define IWL1000_UCODE_API_MAX 5
 #define IWL100_UCODE_API_MAX 5
 
 /* Lowest firmware API version supported */
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
