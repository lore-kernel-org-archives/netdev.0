From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/2] be2net: add vxlan offload support
Date: Thu, 20 Mar 2014 16:10:09 +0530
Message-ID: <1395312011-899-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40909 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaCTKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 06:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch adds the FW cmds needed to configure the Skyhawk-R
chip for supporting VxLAN offloads. The second patch takes care of
implementing the ndo_add/del_vxlan_port() methods and the plumbing
for supporting RX/TX csum, TSO and RSS steering offloads for VxLAN traffic.

Pls apply. Thanks.

Sathya Perla (2):
  be2net: add FW cmds needed for VxLAN offloads
  be2net: csum, tso and rss steering offload support for VxLAN

 drivers/net/ethernet/emulex/benet/be.h      |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  135 ++++++++++++++++++++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   69 ++++++++++----
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  130 +++++++++++++++++++++++---
 5 files changed, 277 insertions(+), 67 deletions(-)
