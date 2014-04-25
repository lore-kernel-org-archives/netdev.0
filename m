From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: Broadcom SYSTEMPORT driver
Date: Thu, 24 Apr 2014 18:08:56 -0700
Message-ID: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:53672 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaDYBJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 21:09:22 -0400
Received: by mail-pb0-f53.google.com with SMTP id jt11so836112pbb.26
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 18:09:22 -0700 (PDT)
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
 drivers/net/ethernet/broadcom/bcmsysport.c         | 1614 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/bcmsysport.h         |  677 ++++++++
 6 files changed, 2338 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-systemport.txt
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.c
 create mode 100644 drivers/net/ethernet/broadcom/bcmsysport.h

-- 
1.9.1
