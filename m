From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 0/2] signal reception fixes
Date: Fri, 13 May 2011 11:02:14 +0530
Message-ID: <93676d63-5688-44b4-a0d0-bb06e634cdbd@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:53988 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755688Ab1EMF2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 01:28:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Incorporated Ben's comment w.r.t replacing schedule_timeout() with msleep()

Sathya Perla (2):
  be2net: handle signal reception while waiting for POST
  be2net: fix mbox polling for signal reception

 drivers/net/benet/be_cmds.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

-- 
1.7.4

