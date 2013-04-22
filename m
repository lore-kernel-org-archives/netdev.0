From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/5] be2net patch-set
Date: Mon, 22 Apr 2013 14:58:13 +0530
Message-ID: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:12512 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052Ab3DVJZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:25:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Craig Hada (1):
  be2net: enable IOMMU pass through for be2net

Vasundhara Volam (4):
  be2net: Use TXQ_CREATE_V2 cmd
  be2net: Don't log "Out of MCCQ wrbs" error
  be2net: Avoid flashing BE3 UFI on BE3-R chip.
  be2net: Use GET_PROFILE_CONFIG V1 cmd for BE3-R

 drivers/net/ethernet/emulex/benet/be.h      |    2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |  136 +++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   63 +++++--------
 drivers/net/ethernet/emulex/benet/be_hw.h   |    7 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   68 ++++++++++----
 5 files changed, 177 insertions(+), 99 deletions(-)
