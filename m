From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH 0/3] [git-pull] net firmware patches
Date: Mon, 30 Mar 2009 20:57:58 +0530
Message-ID: <1238426878.24736.18.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>, frible@teaser.fr,
	becker@scyld.com, d
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:41852 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbZC3P23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 11:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David:

The following changes since commit 7c757eb9f804782fb39d0ae2c1a88ffb9309138e:
  Roland Dreier (1):
        RDMA/nes: Fix mis-merge

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/net-next-2.6.git master

Jaswinder Singh Rajput (3):
      yam: use request_firmware
      3C359: use request_firmware
      smc91c92_cs: use request_firmware

 drivers/net/hamradio/yam.c              |   64 ++-
 drivers/net/hamradio/yam1200.h          |  343 -------
 drivers/net/hamradio/yam9600.h          |  343 -------
 drivers/net/pcmcia/ositech.h            |  358 -------
 drivers/net/pcmcia/smc91c92_cs.c        |   44 +-
 drivers/net/tokenring/3c359.c           |   63 +-
 drivers/net/tokenring/3c359.h           |    3 +
 drivers/net/tokenring/3c359_microcode.h | 1581 -------------------------------
 firmware/3com/3C359.bin.ihex            | 1573 ++++++++++++++++++++++++++++++
 firmware/Makefile                       |    3 +
 firmware/WHENCE                         |   50 +
 firmware/ositech/Xilinx7OD.bin.ihex     |  177 ++++
 firmware/yam/1200.bin.ihex              |  342 +++++++
 firmware/yam/9600.bin.ihex              |  342 +++++++
 14 files changed, 2628 insertions(+), 2658 deletions(-)
 delete mode 100644 drivers/net/hamradio/yam1200.h
 delete mode 100644 drivers/net/hamradio/yam9600.h
 delete mode 100644 drivers/net/pcmcia/ositech.h
 delete mode 100644 drivers/net/tokenring/3c359_microcode.h
 create mode 100644 firmware/3com/3C359.bin.ihex
 create mode 100644 firmware/ositech/Xilinx7OD.bin.ihex
 create mode 100644 firmware/yam/1200.bin.ihex
 create mode 100644 firmware/yam/9600.bin.ihex


