From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 00/10] bna: Update Brocade BNA Ethernet driver to v2.3.2.3
Date: Tue, 21 Dec 2010 23:23:06 -0800
Message-ID: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54444 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752396Ab0LVHwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:52:44 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7ML8s021240
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:20 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tb71ag48e-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:19 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set updates the Brocade BNA driver to v2.3.2.3.

The patches are generated, compiled and tested against net-next-2.6 (2.6.37-rc1).

Rasesh Mody (10):
  bna: TxRx and datapath fix
  bna: Port enable disable sync and txq priority fix
  bna: Fix ethtool register dump and reordered an API
  bna: Enable pure priority tagged packet reception and rxf uninit
    cleanup fix
  bna: Fix for TX queue
  bna: IOC uninit check and misc cleanup
  bna: Removed unused code
  bna: Restore VLAN filter table
  bna: IOC failure auto recovery fix
  bna: Update the driver version to 2.3.2.3

 drivers/net/bna/bfa_defs.h          |   22 +-
 drivers/net/bna/bfa_defs_mfg_comm.h |   22 -
 drivers/net/bna/bfa_ioc.c           | 1219 +++++++++++++++++++++++++----------
 drivers/net/bna/bfa_ioc.h           |   49 +-
 drivers/net/bna/bfa_ioc_ct.c        |  102 +++-
 drivers/net/bna/bfi_ctreg.h         |   41 +-
 drivers/net/bna/bna.h               |    6 +-
 drivers/net/bna/bna_ctrl.c          |  377 +++--------
 drivers/net/bna/bna_txrx.c          |   44 +-
 drivers/net/bna/bna_types.h         |   11 +-
 drivers/net/bna/bnad.c              |  427 +++++++------
 drivers/net/bna/bnad.h              |   37 +-
 drivers/net/bna/bnad_ethtool.c      |    8 +-
 13 files changed, 1445 insertions(+), 920 deletions(-)

