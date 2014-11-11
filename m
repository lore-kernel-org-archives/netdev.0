From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: bcmgenet: power management related fixes
Date: Mon, 10 Nov 2014 18:06:19 -0800
Message-ID: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49647 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaKKCG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:06:26 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so9608078pad.29
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 18:06:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches fixes issues seen while testing power management on
platforms using the GENET driver.

First patch fixes an issue with the PHY state machine queuing work after
resume since we are not properly detached from it.

Second patch fixes an issue with GENET interfaces that were not properly
restored to a working state after a S3 suspend/resume cycle.

Thanks!

Florian Fainelli (2):
  net: bcmgenet: connect and disconnect from the PHY state machine
  net: bcmgenet: apply MII configuration in bcmgenet_open()

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 11 ++++++++++-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  3 ++-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  9 +++++----
 3 files changed, 17 insertions(+), 6 deletions(-)

-- 
1.9.1
