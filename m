From: Ajit Khaparde <ajit.khaparde@broadcom.com>
Subject: [PATCH net-next 0/2] be2net patches
Date: Tue, 23 Feb 2016 00:35:15 +0530
Message-ID: <1456167915-31546-1-git-send-email-ajit.khaparde@broadcom.com>
To: ajit.khaparde@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:53691 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751821AbcBVTHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 14:07:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider applying to net-next

Ajit Khaparde (2):
  Patch 1: Declare some u16 fields as u32 to improve performance
  Patch 2: Fix a UE caused by passing large frames to the ASIC

 drivers/net/ethernet/emulex/benet/be.h      | 21 ++++++++++++---------
 drivers/net/ethernet/emulex/benet/be_cmds.c |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 27 +++++++++++++++++++--------
 3 files changed, 32 insertions(+), 18 deletions(-)

-- 
2.4.3
