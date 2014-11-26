From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: bcmgenet: EEE support
Date: Tue, 25 Nov 2014 21:16:33 -0800
Message-ID: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45031 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaKZFQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:16:41 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so2095212pab.34
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:16:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series add EEE support to the Broadcom GENET driver, first patch
basically adds register definitions for the hardware, the second patch does the
actual implementation and hooks the {get,set}_eee ethtool callbacks, the last
patch adds auto-negotiation restart capability.

Thanks!

Florian Fainelli (3):
  net: bcmgenet: add register definitions for EEE
  net: bcmgenet: add EEE support
  net: bcmgenet: support restarting auto-negotiation

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 104 +++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  26 +++++++
 2 files changed, 130 insertions(+)

-- 
2.1.0
