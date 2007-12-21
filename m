From: dhananjay@netxen.com
Subject: [patch 0/6] netxen bug fixes
Date: Thu, 20 Dec 2007 18:36:56 -0800
Message-ID: <20071221023656.409657310@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:36117 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752639AbXLUCvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 21:51:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending out 4 bugfixes and some improvements for the netxen nic driver.
Also updating driver version and maintainer. The patches are generated
against upstream branch.


 MAINTAINERS                              |    4 +-
 drivers/net/netxen/netxen_nic.h          |   10 +-
 drivers/net/netxen/netxen_nic_hdr.h      |   12 ++
 drivers/net/netxen/netxen_nic_hw.c       |    2 +
 drivers/net/netxen/netxen_nic_init.c     |   65 ++----------
 drivers/net/netxen/netxen_nic_main.c     |  174 ++++++++++--------------------
 drivers/net/netxen/netxen_nic_niu.c      |    8 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |    3 +
 8 files changed, 94 insertions(+), 184 deletions(-)


