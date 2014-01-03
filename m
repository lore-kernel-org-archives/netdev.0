From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 0/5] tg3: Unicast filter support and misc fixes
Date: Fri, 3 Jan 2014 10:09:10 -0800
Message-ID: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:9445 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbaACSJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:09:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan (2):
  tg3: Refactor __tg3_set_mac_addr()
  tg3: Add unicast filtering support.

Nithin Nayak Sujir (3):
  tg3: Set the MAC clock to the fastest speed during boot code load
  tg3: Poll cpmu link state on APE + ASF enabled devices
  tg3: Update version to 3.136

 drivers/net/ethernet/broadcom/tg3.c | 125 ++++++++++++++++++++++++++++++------
 drivers/net/ethernet/broadcom/tg3.h |   5 ++
 2 files changed, 111 insertions(+), 19 deletions(-)

-- 
1.8.1.4
