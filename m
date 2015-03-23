From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/7] net: bcmgenet: integrated GPHY power up/down
Date: Mon, 23 Mar 2015 15:03:44 -0700
Message-ID: <1427148231-18902-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36852 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbbCWWEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:04:36 -0400
Received: by pdbcz9 with SMTP id cz9so200165898pdb.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:04:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series implements integrated Gigabit PHY power up/down, which allows
us to save close to 300mW on some designs when the Gigabit PHY is known to be
unused (e.g: during bcmgenet_close or bcmgenet_suspend not doing Wake-on-LAN).

Thanks!

Florian Fainelli (7):
  net: bcmgenet: propagate errors from bcmgenet_power_down
  net: bcmgenet: update bcmgenet_ephy_power_up to clear CK25_DIS bit
  net: bcmgenet: rename bcmgenet_ephy_power_up
  net: bcmgenet: fix GPHY power-up sequence
  net: bcmgenet: implement GPHY power down sequence
  net: bcmgenet: power up and down integrated GPHY when unused
  net: bcmgenet: power down and up GPHY during suspend/resume

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 34 +++++++++++++++++++-------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  2 ++
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 32 ++++++++++++++++--------
 3 files changed, 49 insertions(+), 19 deletions(-)

-- 
2.1.0
