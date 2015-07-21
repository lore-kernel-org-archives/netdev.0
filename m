From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Mon, 20 Jul 2015 20:44:41 -0700 (PDT)
Message-ID: <20150720.204441.153673057236321524.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D52C48B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbGUDom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:44:42 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D52C48B@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 16 Jul 2015 22:16:05 +0000

> +static int eee_control = -1;
> +module_param(eee_control, int, 0444);
> +MODULE_PARM_DESC(eee_control, "EEPROM default(-1), disable(0) & enable(1)");

Please don't add module parameters for things configurable via ethtool and
other generic, standard, mechanisms.

Thanks.
