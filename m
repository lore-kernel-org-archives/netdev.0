From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH v2 net 0/2] tg3: 2 bugfixes - TSO data corruption and
 phy power down
Date: Mon, 13 May 2013 14:04:14 -0700
Message-ID: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4039 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070Ab3EMVE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 17:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
 - Modify tg3_phy_power_bug() function to use a switch instead of a
   complicated if statement. Suggested by Joe Perches.

Michael Chan (1):
  tg3: Fix data corruption on 5725 with TSO

Nithin Nayak Sujir (1):
  tg3: Skip powering down function 0 on certain serdes devices

 drivers/net/ethernet/broadcom/tg3.c | 49 ++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 6 deletions(-)

-- 
1.8.1.4
