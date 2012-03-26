From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 0/7] bna: Update driver version to 3.0.23.0
Date: Mon, 26 Mar 2012 12:37:53 -0700
Message-ID: <1332790673-9562-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58049 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753564Ab2CZTiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 15:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains fixes in adapter initialization and tx/rx cleanup path.
It also include code cleanups by removing and renaming some functions.

The driver version has been updated to 3.0.23.0 to reflect the changes.

Jing Huang (7):
  bna: Serialize smem access during adapter initialization
  bna: Flash controller ioc pll init fixes
  bna: ioc cleanups
  bfa: tx rx cleanup fix
  bna: Remove tx tasklet
  bfa: Function name changes and cleanups
  bfa: Update driver version to 3.0.23.0

 drivers/net/ethernet/brocade/bna/bfa_ioc.c      |   61 +++--
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c   |  142 +++++++----
 drivers/net/ethernet/brocade/bna/bfi_reg.h      |    6 +
 drivers/net/ethernet/brocade/bna/bnad.c         |  316 +++++++++++------------
 drivers/net/ethernet/brocade/bna/bnad.h         |   11 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    6 +-
 6 files changed, 300 insertions(+), 242 deletions(-)
