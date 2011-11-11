From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/4] be2net fixes
Date: Fri, 11 Nov 2011 10:47:56 +0530
Message-ID: <1320988680-7842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:4695 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751107Ab1KKFUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 00:20:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply. Thanks.

Sathya Perla (4):
  be2net: init (vf)_if_handle/vf_pmac_id to handle failure scenarios
  be2net: stop checking the UE registers after an EEH error
  be2net: don't log more than one error on detecting EEH/UE errors
  be2net: stop issuing FW cmds if any cmd times out

 drivers/net/ethernet/emulex/benet/be.h      |   16 ++++---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   49 +++++++-------------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   66 ++++++++++++++++-----------
 4 files changed, 69 insertions(+), 66 deletions(-)

-- 
1.7.4
