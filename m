From: Robert Schulze <rob@net-pr.de>
Subject: Re: airo maybe should select crypto_aes
Date: Sat, 08 Jul 2006 13:37:17 +0200
Message-ID: <44AF98ED.8000601@net-pr.de>
References: <E1Fz4ZZ-0001V1-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p15181122.pureserver.info ([212.227.60.11]:18643 "EHLO
	p15181122.pureserver.info") by vger.kernel.org with ESMTP
	id S964798AbWGHLcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 07:32:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <E1Fz4ZZ-0001V1-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Herbert Xu schrieb:
> First of your patch is space-damaged.  Please make sure that the
> original tabs are preserved and resend.

Sorry for that, hope it fits this time.

> Also, wireless patches should be sent to this list with a cc to
> John W. Linville <linville@tuxdriver.com>.

Didn't know that.

With kind regards,
Robert Schulze


--- linux-2.6.17.1/drivers/net/wireless/Kconfig.orig	2006-07-03 
17:37:02.000000000 +0200
+++ linux-2.6.17.1/drivers/net/wireless/Kconfig	2006-07-03 
17:36:44.000000000 +0200
@@ -419,6 +419,7 @@ config AIRO_CS
  	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
  	depends on NET_RADIO && PCMCIA && (BROKEN || !M32R)
  	select CRYPTO
+	select CRYPTO_AES
  	---help---
  	  This is the standard Linux driver to support Cisco/Aironet PCMCIA
  	  802.11 wireless cards.  This driver is the same as the Aironet


