From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: systemport: PM and Wake-on-LAN support
Date: Tue,  1 Jul 2014 21:08:35 -0700
Message-ID: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42714 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaGBEJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:07 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so8353536qae.19
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset brings Power Management and Wake-on-LAN support to the
Broadcom SYSTEM PORT driver.

S2 and S3 modes are supported, while we only support Wake-on-LAN using
MagicPackets for now

Florian Fainelli (5):
  net: systemport: update umac_enable_set to take a bitmask
  net: systemport: add bcm_sysport_netif_{enable,stop}
  net: systemport: add suspend and resume support
  net: systemport: rename rx_csum_en to rx_chk_en
  net: systemport: add Wake-on-LAN support

 .../bindings/net/broadcom-systemport.txt           |   3 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         | 378 +++++++++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h         |  14 +-
 3 files changed, 361 insertions(+), 34 deletions(-)

-- 
1.9.1
