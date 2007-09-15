From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Sat, 15 Sep 2007 09:21:34 -0400
Message-ID: <20070915132134.GD6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff,

A few more for 2.6.24...

Thanks,

John

---

The following changes since commit 18d256761aa268fd2fb113c4fd26c400431f1dc1:
  Jeff Garzik (1):
        Merge branch 'stats' into upstream

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

Jesper Juhl (1):
      zd1211rw: Don't needlessly initialize variable to NULL in zd_chip

Larry Finger (1):
      bcm43xx: Change radio hardware switch status printk from debug to regular

Ulrich Kunitz (1):
      zd1211rw: add USB id for Telegent TG54USB WLAN adapter

 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    4 ++--
 drivers/net/wireless/zd1211rw/zd_chip.c     |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    1 +
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 618d1a2..4d84631 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2380,7 +2380,7 @@ static int bcm43xx_chip_init(struct bcm43xx_private *bcm)
 		goto err_gpio_cleanup;
 	bcm43xx_radio_turn_on(bcm);
 	bcm->radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
-	dprintk(KERN_INFO PFX "Radio %s by hardware\n",
+	printk(KERN_INFO PFX "Radio %s by hardware\n",
 		(bcm->radio_hw_enable == 0) ? "disabled" : "enabled");
 
 	bcm43xx_write16(bcm, 0x03E6, 0x0000);
@@ -3129,7 +3129,7 @@ static void bcm43xx_periodic_every1sec(struct bcm43xx_private *bcm)
 	radio_hw_enable = bcm43xx_is_hw_radio_enabled(bcm);
 	if (unlikely(bcm->radio_hw_enable != radio_hw_enable)) {
 		bcm->radio_hw_enable = radio_hw_enable;
-		dprintk(KERN_INFO PFX "Radio hardware status changed to %s\n",
+		printk(KERN_INFO PFX "Radio hardware status changed to %s\n",
 		       (radio_hw_enable == 0) ? "disabled" : "enabled");
 		bcm43xx_leds_update(bcm, 0);
 	}
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 4959042..06244d8 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -106,7 +106,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 {
 	int r;
 	int i;
-	zd_addr_t *a16 = (zd_addr_t *)NULL;
+	zd_addr_t *a16;
 	u16 *v16;
 	unsigned int count16;
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index e49628b..895ff84 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -55,6 +55,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x14ea, 0xab13), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x13b1, 0x001e), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3407), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x129b, 0x1666), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
