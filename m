From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/5] be2net: fixes
Date: Fri, 24 Feb 2012 10:20:12 +0530
Message-ID: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755089Ab2BXEzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply the following fixes. Thanks.

Sathya Perla (5):
  be2net: cancel be_worker during EEH recovery
  be2net: fix tx completion cleanup
  be2net: reset queue address after freeing
  be2net: enable RSS for ipv6 pkts
  be2net: update driver version

 drivers/net/ethernet/emulex/benet/be.h      |    3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   92 +++++++++++++++-----------
 3 files changed, 57 insertions(+), 41 deletions(-)

-- 
1.7.4
