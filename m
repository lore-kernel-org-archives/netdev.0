From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'p54' branch of wireless-2.6
Date: Wed, 19 Sep 2007 15:55:27 -0400
Message-ID: <20070919195527.GD5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Michael Wu <flamingice@sourmilk.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3118 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbXISUKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 16:10:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff & Dave,

This patch adds the p54 driver for prism54 hardware using the "soft
MAC" firmware.  It includes modules for both PCI and USB drivers.

This driver has been in Fedora (both F7 and rawhide) for some time
and has generally performed well.  No doubt there are some problems
with the code, but still I think it would be better to mainline the
driver than to keep it out of stream.

Thanks,

John

---

The patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/p54/0001-p54-add-mac80211-based-driver-for-prism54-softmac.patch

---

The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
  Linus Torvalds (1):
        Linux 2.6.23-rc6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git p54

Michael Wu (1):
      p54: add mac80211-based driver for prism54 softmac hardware

 MAINTAINERS                      |    8 +
 drivers/net/wireless/Kconfig     |   13 +
 drivers/net/wireless/Makefile    |    4 +
 drivers/net/wireless/net2280.h   |  452 +++++++++++++++++
 drivers/net/wireless/p54.h       |   80 +++
 drivers/net/wireless/p54common.c |  983 ++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/p54common.h |  329 +++++++++++++
 drivers/net/wireless/p54pci.c    |  689 ++++++++++++++++++++++++++
 drivers/net/wireless/p54pci.h    |  106 ++++
 drivers/net/wireless/p54usb.c    |  904 +++++++++++++++++++++++++++++++++++
 drivers/net/wireless/p54usb.h    |  133 +++++
 11 files changed, 3701 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wireless/net2280.h
 create mode 100644 drivers/net/wireless/p54.h
 create mode 100644 drivers/net/wireless/p54common.c
 create mode 100644 drivers/net/wireless/p54common.h
 create mode 100644 drivers/net/wireless/p54pci.c
 create mode 100644 drivers/net/wireless/p54pci.h
 create mode 100644 drivers/net/wireless/p54usb.c
 create mode 100644 drivers/net/wireless/p54usb.h
-- 
John W. Linville
linville@tuxdriver.com
