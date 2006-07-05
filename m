From: Robert Schulze <rob@net-pr.de>
Subject: airo maybe should select crypto_aes
Date: Wed, 05 Jul 2006 22:52:43 +0200
Message-ID: <44AC269B.6000704@net-pr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from p15181122.pureserver.info ([212.227.60.11]:48556 "EHLO
	p15181122.pureserver.info") by vger.kernel.org with ESMTP
	id S964868AbWGEUrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 16:47:31 -0400
Received: from [192.168.0.123] (dialin-145-254-053-026.pools.arcor-ip.net [145.254.53.26])
	by p15181122.pureserver.info (Postfix) with ESMTP id CE4B3808EA9
	for <netdev@vger.kernel.org>; Wed,  5 Jul 2006 22:47:31 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I first wrote to the linux-pcmcia ML, but they said it wasn't the right 
address for my issue. The driver airo (for Cisco Wlan-Cards) complains 
about "failed to load transform for AES", when it is loaded and 
CRYPTO_AES is not selected in Kconfig.
I've got a patch for that, maybe it's worth it.

with kind regards,
Robert Schulze

--- linux-2.6.17.1/drivers/net/wireless/Kconfig.orig    2006-07-03
17:37:02.000000000 +0200
+++ linux-2.6.17.1/drivers/net/wireless/Kconfig 2006-07-03
17:36:44.000000000 +0200
@@ -419,6 +419,7 @@ config AIRO_CS
          tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
          depends on NET_RADIO && PCMCIA && (BROKEN || !M32R)
          select CRYPTO
+       select CRYPTO_AES
          ---help---
            This is the standard Linux driver to support Cisco/Aironet 
PCMCIA
            802.11 wireless cards.  This driver is the same as the Aironet



