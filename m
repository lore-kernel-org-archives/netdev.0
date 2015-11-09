From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.4] NFC fixes
Date: Mon, 9 Nov 2015 02:02:31 +0100
Message-ID: <20151109010231.GA31406@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45549 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbbKIBCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 20:02:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is the 1st NFC fixes pull request for 4.4.

It includes bug fixes and one fix for a build failure, all of them
introduced with the first NFC pull request for 4.4.

We have:

- Fix nfcmrvl SPI driver potential build error due to a broken Kconfig
  dependency.
- A few fixes for the firmware download implementation for the nfcmrvl
  UART driver.
- A GPIO allocation leak for the nfcmrvl driver.
- One code simplification for the nfcmrvl DT handling.

The following changes since commit 1b1050cdc5cdde43177b375b5f22dc070d45d8f8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2015-11-04 10:12:43 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-fixes.git tags/nfc-fixes-4.4-1

for you to fetch changes up to 82aff3ea3b87892ce1476dad83de211741b3ac00:

  NFC: nfcmrvl: avoid being stuck on FW dnld timeout (2015-11-05 00:32:25 +0100)

----------------------------------------------------------------
Arnd Bergmann (1):
      NFC: nfcmrvl: fix SPI driver dependencies

Vincent Cuissard (5):
      NFC: nfcmrvl: avoid UART break control during FW download
      NFC: nfcmrvl: add a small wait after setting UART break
      NFC: nfcmrvl: free reset gpio
      NFC: nfcmrvl: remove unneeded CONFIG_OF switches
      NFC: nfcmrvl: avoid being stuck on FW dnld timeout

 drivers/nfc/nfcmrvl/Kconfig   |  2 +-
 drivers/nfc/nfcmrvl/fw_dnld.c | 12 +++++++++---
 drivers/nfc/nfcmrvl/main.c    | 15 +++------------
 drivers/nfc/nfcmrvl/uart.c    | 26 +++++++++-----------------
 4 files changed, 22 insertions(+), 33 deletions(-)
