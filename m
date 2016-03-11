From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.6] NFC update
Date: Fri, 11 Mar 2016 21:48:57 +0100
Message-ID: <20160311204857.GB29902@zurbaran.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFC <linux-nfc@lists.01.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148AbcCKUtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 15:49:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is a very small one this time, with only 5 patches.
There are a couple of big items that could not be merged/finished
on time.

We have:

- 2 LLCP fixes for a race and a potential OOM.
- 2 cleanups for the pn544 and microread drivers.
- 1 Maintainer addition for the s3fwrn5 driver.


The following changes since commit 667f00630ebefc4d73aa105c6ab254e4aec867f8:

  Merge branch 'local-checksum-offload' (2016-02-12 05:52:41 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.6-1

for you to fetch changes up to 079c2652e5af648db6bf4f54bcafdafcc57a0d2c:

  MAINTAINERS: nfc: s3fwrn5: Add second maintainer (2016-03-10 17:16:22 +0100)

----------------------------------------------------------------
Cong Wang (2):
      NFC: Use GFP_USER for user-controlled kmalloc
      NFC: Close a race condition in llcp_sock_getname()

Jean Delvare (1):
      NFC: microread: Drop platform data header file

Mika Westerberg (1):
      NFC: pn544: Drop two useless checks in ACPI probe path

Robert Baldyga (1):
      MAINTAINERS: nfc: s3fwrn5: Add second maintainer

 MAINTAINERS                             |  2 +-
 drivers/nfc/microread/i2c.c             |  8 --------
 drivers/nfc/pn544/i2c.c                 | 14 +------------
 include/linux/platform_data/microread.h | 35 ---------------------------------
 net/nfc/llcp_commands.c                 |  4 ++--
 net/nfc/llcp_sock.c                     |  6 ++++++
 6 files changed, 10 insertions(+), 59 deletions(-)
 delete mode 100644 include/linux/platform_data/microread.h
