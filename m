From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH 0/2] phylib: mdio-ofgpio ---> mdio-gpio (v2)
Date: Fri, 31 Oct 2008 18:45:15 +0200
Message-ID: <20081031164132.20490.27608.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:37097 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751154AbYJaQtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 12:49:23 -0400
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 31 Oct 2008 16:43:51 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:
- broken to rename patch and mdio-gpio rework

---

Paulius Zaleckas (2):
      phylib: make mdio-gpio work without OF
      phylib: rename mdio-ofgpio to mdio-gpio


 drivers/net/phy/Kconfig       |    7 +
 drivers/net/phy/Makefile      |    2 
 drivers/net/phy/mdio-gpio.c   |  308 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/mdio-ofgpio.c |  204 ---------------------------
 include/linux/mdio-gpio.h     |   30 ++++
 5 files changed, 344 insertions(+), 207 deletions(-)
 create mode 100644 drivers/net/phy/mdio-gpio.c
 delete mode 100644 drivers/net/phy/mdio-ofgpio.c
 create mode 100644 include/linux/mdio-gpio.h
