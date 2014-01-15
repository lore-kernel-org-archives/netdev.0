From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 00/11] be2net: patch set
Date: Wed, 15 Jan 2014 13:23:30 +0530
Message-ID: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20734 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbaAOHtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set is best suited for net-next as it
contains code-cleanup, support for newer versions of FW cmds and
a few minor fixes. Please apply. Thanks!

Sathya Perla (1):
  be2net: updated driver version (10.0.x)

Suresh Reddy (5):
  be2net: fix incorrect setting of cmd_privileges for VFs
  be2net: Remove "10Gbps" from driver description string
  be2net: do not use frag index in the RX-compl entry
  be2net: use GET_MAC_LIST cmd to query mac-address from a pmac-id
  be2net: cleanup wake-on-lan code

Vasundhara Volam (5):
  be2net: Use MCC_CREATE_EXT_V1 cmd for Skyhawk-R
  be2net: don't set "pport" field when querying "pvid"
  be2net: Log the profile-id used by FW during driver initialization
  be2net: do not call be_set/get_fw_log_level() on Skyhawk-R
  be2net: ignore mac-addr set call for an already programmed mac-addr

 drivers/net/ethernet/emulex/benet/be.h         |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  178 +++++++++++++++++++-----
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   33 ++++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   73 ++--------
 drivers/net/ethernet/emulex/benet/be_main.c    |  137 +++++-------------
 5 files changed, 227 insertions(+), 201 deletions(-)
