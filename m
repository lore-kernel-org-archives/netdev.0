From: dhananjay@netxen.com
Subject: [patch 0/7] netxen bug fixes
Date: Wed, 26 Dec 2007 10:23:52 -0800
Message-ID: <20071226182352.704678179@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:45022 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750883AbXLZSZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 13:25:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending recent patch set with an additional patch to fix byte
ordering in tx desc besides the original bug fixes and some
enhancements in tx and rx.

Recreated these patches from a fresh cloned tree.

Thanks,
	Dhananjay

-- 
 MAINTAINERS                              |    4 +-
 drivers/net/netxen/netxen_nic.h          |   76 +++++++-------
 drivers/net/netxen/netxen_nic_hdr.h      |   12 ++
 drivers/net/netxen/netxen_nic_hw.c       |    2 +
 drivers/net/netxen/netxen_nic_init.c     |   77 +++-----------
 drivers/net/netxen/netxen_nic_main.c     |  174 ++++++++++--------------------
 drivers/net/netxen/netxen_nic_niu.c      |    8 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |    3 +
 8 files changed, 133 insertions(+), 223 deletions(-)
