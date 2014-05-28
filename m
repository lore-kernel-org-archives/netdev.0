From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/6] be2net: patch set
Date: Wed, 28 May 2014 12:00:59 +0530
Message-ID: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:54805 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbaE1G2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 02:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 is a minor optimization for issuing multicast promisc FW cmd
only when the interface is not already in that mode.

Patch 2 provides support for VF TX-rate setting on Skyhawk-R.

Patch 3 provides support for flashing new FW flash regions.

Patches 4, 5, 6 cleanup the MCC processing (for FW cmds) code in be_cmds.c.
The MCC error reporting and event handling code are areas that needed
cleanup.

Pls consider applying to the net-next tree. Thanks.

Kalesh AP (2):
  be2net: re-factor multicast promiscuos setting
  be2net: re-factor MCCQ error status handling code

Ravikumar Nelavelli (1):
  be2net: fixup TX-rate setting code for Skyhawk-R

Sathya Perla (2):
  be2net: move async cmd processing to a separate routine
  be2net: cleanup MCC async event processing code

Vasundhara Volam (1):
  be2net: support flashing new regions on Skyhawk-R

 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |  275 ++++++++++++---------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   81 ++++---
 drivers/net/ethernet/emulex/benet/be_hw.h   |   12 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  353 +++++++++++++++++----------
 5 files changed, 439 insertions(+), 283 deletions(-)
