From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'libertas-fixes' branch of wireless-2.6
Date: Tue, 3 Jul 2007 14:48:13 -0400
Message-ID: <20070703184813.GC3534@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following changes since commit aa2e09da2a332e748532aa2a71b090e7e7c3203d:
  Len Brown (1):
        ACPI: fix acpi_osi=!Linux

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git libertas-fixes

Holger Schurig (1):
      libertas: fix use-after-free in rx path

Robert P. J. Day (1):
      WIRELESS: Remove clearly obsolete libertas/version.h file.

 drivers/net/wireless/libertas/rx.c      |    1 -
 drivers/net/wireless/libertas/version.h |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/version.h

diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 88d9d2d..769c86f 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -439,7 +439,6 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	ret = 0;
 
 done:
-	skb->protocol = __constant_htons(0x0019);	/* ETH_P_80211_RAW */
 	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", ret);
 	return ret;
 }
diff --git a/drivers/net/wireless/libertas/version.h b/drivers/net/wireless/libertas/version.h
deleted file mode 100644
index 8b13789..0000000
--- a/drivers/net/wireless/libertas/version.h
+++ /dev/null
@@ -1 +0,0 @@
-

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
