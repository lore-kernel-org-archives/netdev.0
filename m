From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-04-30
Date: Fri, 30 Apr 2010 14:08:40 -0400
Message-ID: <20100430180840.GD4120@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

One more for 2.6.34...it avoids some DMA mapping-related failures.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 03f80cc3f24e1dcdbdba081ed5daf5575aac6180:
  Sebastian Siewior (1):
        net/sb1250: register mdio bus in probe

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Hans de Goede (1):
      p54pci: fix bugs in p54p_check_tx_ring

 drivers/net/wireless/p54/p54pci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index ed4bdff..21f673d 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -245,7 +245,7 @@ static void p54p_check_tx_ring(struct ieee80211_hw *dev, u32 *index,
 	u32 idx, i;
 
 	i = (*index) % ring_limit;
-	(*index) = idx = le32_to_cpu(ring_control->device_idx[1]);
+	(*index) = idx = le32_to_cpu(ring_control->device_idx[ring_index]);
 	idx %= ring_limit;
 
 	while (i != idx) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
