From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 0/2] be2net: 64-bit stats
Date: Tue, 26 Jul 2011 10:40:13 +0530
Message-ID: <1311657015-23465-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:33605 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750828Ab1GZFJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 01:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (2):
  be2net: cleanup and refactor stats code
  be2net: use stats-sync to read/write 64-bit stats

 drivers/net/benet/be.h         |  115 +++++++--------
 drivers/net/benet/be_cmds.c    |   21 ---
 drivers/net/benet/be_cmds.h    |   53 +------
 drivers/net/benet/be_ethtool.c |  122 +++++++---------
 drivers/net/benet/be_main.c    |  326 +++++++++++++++-------------------------
 5 files changed, 239 insertions(+), 398 deletions(-)

-- 
1.7.4

