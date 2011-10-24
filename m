From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/4] be2net: fixes
Date: Mon, 24 Oct 2011 18:14:59 +0530
Message-ID: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:57529 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932239Ab1JXMpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (4):
  be2net: add vlan/rx-mode/flow-control config to be_setup()
  be2net: refactor VF setup/teardown code into be_vf_setup/clear()
  be2net: don't create multiple TXQs in BE2
  be2net: don't create multiple RX/TX rings in multi channel mode

 drivers/net/ethernet/emulex/benet/be_cmds.c |   66 +++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |   10 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  362 +++++++++++++--------------
 3 files changed, 222 insertions(+), 216 deletions(-)

-- 
1.7.4
