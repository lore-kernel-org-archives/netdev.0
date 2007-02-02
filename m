From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull "upstream-fixes" branch of wireless-2.6
Date: Fri, 2 Feb 2007 16:27:47 -0500
Message-ID: <20070202212747.GC9382@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4547 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946098AbXBBVf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 16:35:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a fix for 2.6.20 (time permitting).

---

The following changes since commit f56df2f4db6e4af87fb8e941cff69f4501a111df:
  Linus Torvalds (1):
        Linux 2.6.20-rc7

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Maxime Austruy (1):
      zd1211rw: fix potential leak in usb_init

 drivers/net/wireless/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 605e96e..2468ad6 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1128,6 +1128,7 @@ static int __init usb_init(void)
 
 	r = usb_register(&driver);
 	if (r) {
+		destroy_workqueue(zd_workqueue);
 		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
 		       driver.name, r);
 		return r;
-- 
John W. Linville
linville@tuxdriver.com
