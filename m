From: "Erik Ekman" <root@kryo.se>
Subject: [PATCH] Trivial Kconfig fact correction
Date: Tue, 31 Jul 2007 16:56:17 +0200
Message-ID: <f50a3dc50707310756j4f9c8437maf4bc761c076c77@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:63312 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761775AbXGaO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 10:56:18 -0400
Received: by rv-out-0910.google.com with SMTP id k20so614145rvb
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 07:56:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] Trivial Kconfig fact correction

This error seems to have been in the kernel for a long time.

Signed-off-by: Erik Ekman <root@kryo.se>

--- orig/drivers/net/wireless/Kconfig   2007-07-23 10:01:46.000000000 +0200
+++ edit/drivers/net/wireless/Kconfig   2007-07-31 16:47:26.000000000 +0200
@@ -130,7 +130,7 @@ comment "Wireless 802.11 Frequency Hoppi
        depends on NET_RADIO && PCMCIA

 config PCMCIA_RAYCS
-       tristate "Aviator/Raytheon 2.4MHz wireless support"
+       tristate "Aviator/Raytheon 2.4GHz wireless support"
depends on NET_RADIO && PCMCIA
        ---help---
          Say Y here if you intend to attach an Aviator/Raytheon PCMCIA
