From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 0/6] be2net: patch set
Date: Tue, 1 Oct 2013 15:59:55 +0530
Message-ID: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8674 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab3JAK0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply the following patches to the net-next tree. Thanks.

Sathya Perla (2):
  be2net: fix adaptive interrupt coalescing
  be2net: add a counter for pkts dropped in xmit path

Vasundhara Volam (4):
  be2net: Call be_vf_setup() even when VFs are enbaled from previous
    load
  be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd
  be2net: Create single TXQ on BE3-R 1G ports
  be2net: call ENABLE_VF cmd for Skyhawk-R too

 drivers/net/ethernet/emulex/benet/be.h         |   22 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   22 +++--
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   15 ++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   33 ++++---
 drivers/net/ethernet/emulex/benet/be_main.c    |  135 ++++++++++++++----------
 5 files changed, 135 insertions(+), 92 deletions(-)
