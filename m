From: <kgudipat@brocade.com>
Subject: [PATCH 0/2] bna: Enable ethtool flash management and debugfs interface.
Date: Thu, 22 Dec 2011 15:29:07 -0800
Message-ID: <1324596547-7646-1-git-send-email-kgudipat@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <kgudipat@brocade.com>,
	<rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46473 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334Ab1LWAKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 19:10:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Gudipati <kgudipat@brocade.com>

Hi Dave,

	The following patch-set enhances BNA ethtool to support flash management
using eeprom entry points and also enables debugfs support for BNA driver to
collect firmware traces, saved firmware trace in the flash on an IOC crash and to
perform register reads/writes.

	The patch is compiled and tested against latest net-next kernel.

Thanks,
Krishna

Krishna Gudipati (2):
  bna: Added flash sub-module and ethtool eeprom entry points.
  bna: Add debugfs interface.

 drivers/net/ethernet/brocade/bna/Makefile       |    2 +-
 drivers/net/ethernet/brocade/bna/bfa_cee.c      |   35 ++
 drivers/net/ethernet/brocade/bna/bfa_cee.h      |    4 +-
 drivers/net/ethernet/brocade/bna/bfa_defs.h     |   98 +++--
 drivers/net/ethernet/brocade/bna/bfa_ioc.c      |  493 ++++++++++++++++++
 drivers/net/ethernet/brocade/bna/bfa_ioc.h      |   54 ++
 drivers/net/ethernet/brocade/bna/bfi.h          |   97 ++++
 drivers/net/ethernet/brocade/bna/bna_enet.c     |   13 +-
 drivers/net/ethernet/brocade/bna/bna_types.h    |    1 +
 drivers/net/ethernet/brocade/bna/bnad.c         |   52 ++-
 drivers/net/ethernet/brocade/bna/bnad.h         |   27 +
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c |  623 +++++++++++++++++++++++
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |  142 +++++-
 13 files changed, 1598 insertions(+), 43 deletions(-)
 create mode 100644 drivers/net/ethernet/brocade/bna/bnad_debugfs.c

-- 
1.7.3.rc1
