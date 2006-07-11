From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: [PATCH] rt2x00 makefile
Date: Tue, 11 Jul 2006 16:09:33 +0200
Message-ID: <a32f33a40607110709r6e6e5f03y18149fa9cf3b110d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:10454 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750808AbWGKOJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 10:09:34 -0400
Received: by py-out-1112.google.com with SMTP id x31so1675829pye
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 07:09:33 -0700 (PDT)
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

This patch fixes a copy&paste error by correcting the name
for hardware button support in rt61pci.

Please apply to wireless-dev.

Thanks.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig
wireless-dev-end/drivers/net/wireless/d80211/rt2x00/Kconfig
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-07-11
15:44:19.000000000 +0200
+++ wireless-dev-end/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-07-11
16:01:59.000000000 +0200
@@ -61,7 +61,7 @@ config RT61PCI

 	When compiled as a module, this driver will be called "rt61pci.ko".

-config RT2500PCI_BUTTON
+config RT61PCI_BUTTON
 	bool "Ralink rt61 hardware button support"
 	depends on RT61PCI && X86
 	---help---
