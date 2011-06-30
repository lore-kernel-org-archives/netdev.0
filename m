From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 0/3] be2net fixes
Date: Thu, 30 Jun 2011 15:01:41 +0530
Message-ID: <1309426301-15783-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:15836 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750892Ab1F3Jbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 05:31:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (3):
  be2net: fix certain cmd failure logging
  be2net: create/destroy rx-queues on interface open/close
  be2net: clear intr bit in be_probe()

 drivers/net/benet/be_cmds.c |   74 +++++++++++++++++++++++------
 drivers/net/benet/be_cmds.h |   19 +++----
 drivers/net/benet/be_main.c |  111 ++++++++++++++++++++++++++++--------------
 3 files changed, 141 insertions(+), 63 deletions(-)

-- 
1.7.4

