From: ajit.khaparde@broadcom.com
Subject: [PATCH net-next 0/2] be2net Patch series
Date: Wed, 10 Feb 2016 22:45:52 +0530
Message-ID: <1455124554-7819-1-git-send-email-ajit.khaparde@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:52735 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752661AbcBJRRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 12:17:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@broadcom.com>

Please consider applying these two patches to net-next

  Patch-1: Request RSS capability of Rx interface depending on number of
    Rx rings
  Patch-2: Interpret and log new data that's added to the port
    misconfigure async event

 drivers/net/ethernet/emulex/benet/be.h      |  5 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c | 99 +++++++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_cmds.h | 45 ++++++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c | 69 ++++++++++++++------
 4 files changed, 163 insertions(+), 55 deletions(-)

-- 
2.4.3
