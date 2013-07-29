From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/6] tg3: Misc changes
Date: Mon, 29 Jul 2013 13:58:34 -0700
Message-ID: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2624 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954Ab3G2U6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a few minor fixes and a minor ptp feature.


Nithin Nayak Sujir (6):
  tg3: Remove incorrect switch to aux power
  tg3: Allow NVRAM programming when interface is down
  tg3: Implement the shutdown handler
  tg3: Enable support for timesync gpio output
  tg3: Fix UDP fragments treated as RMCP
  tg3: Update version to 3.133

 drivers/net/ethernet/broadcom/tg3.c | 103 +++++++++++++++++++++++++++++-------
 drivers/net/ethernet/broadcom/tg3.h |  12 ++++-
 2 files changed, 94 insertions(+), 21 deletions(-)

-- 
1.8.1.4
