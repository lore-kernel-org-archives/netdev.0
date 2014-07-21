From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 00/11] net: bcmgenet: PM and Wake-on-LAN
Date: Mon, 21 Jul 2014 15:29:18 -0700
Message-ID: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:41452 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbaGUW3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:47 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so9993556pdj.1
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset brings S2/S3 Power Management support to the GENET driver
as well as Wake-on-LAN using Magic Packets with or without SecureOn
passwords.

Thanks!

Florian Fainelli (11):
  net: bcmgenet: remove wol_enabled conditional code
  net: bcmgenet: add umac_enable_set helper
  net: bcmgenet: modularize bcmgenet_{open,close}
  net: bcmgenet: add suspend/resume callbacks
  net: bcmgenet: request Wake-on-LAN interrupt
  net: bcmgenet: add Wake-on-LAN support code
  net: bcmgenet: handle GENET_POWER_WOL_MAGIC
  net: bcmgenet: handle UMAC_IRQ_MPD_R interrupt bit
  net: bcmgenet: fix bcmgenet_wol_resume
  net: bcmgenet: suspend and resume from Wake-on-LAN
  net: bcmgenet: hook ethtool set/get_wol operations

 drivers/net/ethernet/broadcom/genet/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 270 ++++++++++++++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  12 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 206 ++++++++++++++++
 4 files changed, 430 insertions(+), 60 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c

-- 
1.9.1
