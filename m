From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/6] atl1: bugfix, cleanup, enhancement
Date: Wed, 14 Feb 2007 20:11:06 -0600
Message-ID: <20070215021106.GA9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964831AbXBOCLS@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Please accept the following patchset for the atl1 network device driver.

* Drop unnecessary NET_PCI config
* Fix incorrect hash table address
* Read MAC address from register
* Remove unused define
* Add Attansic L1 device id to pci_ids
* Bump version number

This patchset contains changes to the following files.

 drivers/net/Kconfig          |    2 +-
 drivers/net/atl1/atl1_hw.c   |   37 +++++++++++++++++++++----------------
 drivers/net/atl1/atl1_main.c |    5 ++---
 include/linux/pci_ids.h      |    1 +
 4 files changed, 25 insertions(+), 20 deletions(-)
