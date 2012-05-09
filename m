From: Catherine Sullivan <catherine.sullivan@intel.com>
Subject: [NET_NEXT RFC PATCH 0/3] Series short description
Date: Wed, 09 May 2012 16:09:34 -0700
Message-ID: <20120509230814.31910.80709.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:55562 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab2EIXG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 19:06:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add debugfs support to the ixgbe driver to give users the
ability to call functions registered in netdev_ops (simulating kernel actions)
as well as the ability to read and write to individual HW registers on the fly.
These options can be useful when debugging and unit testing ixgbe.

The following series implements...

---

Catherine Sullivan (3):
      ixgbe: added reg_ops file to debugfs
      ixgbe: added netdev_ops file to debugfs
      ixgbe: add debugfs support


 drivers/net/ethernet/intel/ixgbe/Makefile        |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   10 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c |  293 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   17 +
 4 files changed, 320 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c

-- 
Catherine Sullivan
