From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 62/62] zd1211rw: Use const
Date: Sat, 20 Nov 2010 18:39:03 -0800
Message-ID: <15a8b7cda630f3514fd640a2ffd8a84f57e4f084.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark arrays const that are unmodified after initializations.

   text	   data	    bss	    dec	    hex	filename
  19291	     56	   4136	  23483	   5bbb	drivers/net/wireless/zd1211rw/zd_chip.o.old
  19291	     56	   4136	  23483	   5bbb	drivers/net/wireless/zd1211rw/zd_chip.o.new

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/zd1211rw/zd_chip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 87a95bc..30f8d40 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1448,7 +1448,7 @@ int zd_rfwritev_locked(struct zd_chip *chip,
  */
 int zd_rfwrite_cr_locked(struct zd_chip *chip, u32 value)
 {
-	struct zd_ioreq16 ioreqs[] = {
+	const struct zd_ioreq16 ioreqs[] = {
 		{ CR244, (value >> 16) & 0xff },
 		{ CR243, (value >>  8) & 0xff },
 		{ CR242,  value        & 0xff },
@@ -1475,7 +1475,7 @@ int zd_rfwritev_cr_locked(struct zd_chip *chip,
 int zd_chip_set_multicast_hash(struct zd_chip *chip,
 	                       struct zd_mc_hash *hash)
 {
-	struct zd_ioreq32 ioreqs[] = {
+	const struct zd_ioreq32 ioreqs[] = {
 		{ CR_GROUP_HASH_P1, hash->low },
 		{ CR_GROUP_HASH_P2, hash->high },
 	};
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
