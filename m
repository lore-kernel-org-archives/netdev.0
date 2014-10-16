From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] Add support for few debugfs entries
Date: Thu, 16 Oct 2014 06:52:00 +0530
Message-ID: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46059
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751001AbaJPBQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:16:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds a new file for debugfs and support for devlog, cim_la,
cim_la_qcfg and mps_tcam debugfs entries.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Add cxgb4_debugfs.c and devlog support
  cxgb4: Add support for cim_la entry in debugfs
  cxgb4: Add support for cim_la_qcfg entry in debugfs
  cxgb4: Add support for mps_tcam debugfs

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   17 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  683 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   64 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  121 +---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  155 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   19 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   52 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   72 ++
 9 files changed, 1091 insertions(+), 94 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
