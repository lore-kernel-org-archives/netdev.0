From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/2] tg3: Fix boot code initialization
 handshake bug
Date: Tue, 21 May 2013 15:57:31 -0700
Message-ID: <1369177053-7117-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3127 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446Ab3EUW5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:57:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue that was recently observed on one platform after few
hundred suspend/resume loops. The code has existed since day one and affects
every tg3 device. Due to the scope of the devices affected, submitting this
patch to net-next to let it bake for sometime before submitting to stable.

Nithin Nayak Sujir (2):
  tg3: Ensure boot code has completed initialization before accessing
    hardware
  tg3: Update version to 3.132

 drivers/net/ethernet/broadcom/tg3.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
1.8.1.4
