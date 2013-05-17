From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/4] tg3: Add set_eee and get_eee handlers.
Date: Fri, 17 May 2013 08:19:46 -0700
Message-ID: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4468 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753669Ab3EQPUA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for modifying EEE settings via ethtool. Since this can
impact Link Flap Avoidance, the driver pulls the current hardware settings if
LFA is enabled. This is similar to how we do the link settings to avoid a flap.

Nithin Nayak Sujir (4):
  tg3: Add ethtool_eee struct and tg3_setup_eee()
  tg3: Add tg3_eee_pull_config() function
  tg3: Simplify tg3_phy_eee_config_ok() by reusing tg3_eee_pull_config()
  tg3: Implement set/get_eee handlers

 drivers/net/ethernet/broadcom/tg3.c | 227 +++++++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/tg3.h |   1 +
 2 files changed, 174 insertions(+), 54 deletions(-)

-- 
1.8.1.4
