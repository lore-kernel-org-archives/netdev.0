From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1 V6] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
Date: Mon, 15 Feb 2010 14:33:43 +0100
Message-ID: <1266240824-535-1-git-send-email-kristoffer@gaisler.com>
Cc: davem@davemloft.net, Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:41956 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751091Ab0BONeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 08:34:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.

V6: Use resource and irq from of_device instead of using of_get_property.

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    8 +
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1645 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  143 +++++
 5 files changed, 1803 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

