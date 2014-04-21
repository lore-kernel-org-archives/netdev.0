From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: Broadcom SYSTEMPORT driver
Date: Mon, 21 Apr 2014 10:31:30 -0700
Message-ID: <1398101494-27959-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:40483 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbaDURbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:31:41 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so4208163iec.3
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 10:31:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset adds support for the Broadcom SYSTEMPORT Ethernet MAC controller
which is used in the latest Broadcom BCM7xxx Set Top Box System-on-a-Chip. This
Ethernet MAC is interfaced to an internal switch which will get a separate
driver submitted later on.

Thanks!

Florian Fainelli (4):
  net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver
  Documentation: add Broadcom SYSTEMPORT Device Tree bindings
  net: systemport: hook SYSTEMPORT driver in the build
  MAINTAINERS: add Broadcom SYSTEMPORT driver entry

 .../bindings/net/broadcom-systemport.txt           |   29 +
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/broadcom/Kconfig              |   11 +
 drivers/net/ethernet/broadcom/Makefile             |    1 +
 drivers/net/ethernet/broadcom/bcmsysport.c         | 1590 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h         |  675 +++++++++
 6 files changed, 2312 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-systemport.txt
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.c
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.h

-- 
1.9.1
