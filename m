From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] Microchip's LAN7800 family USB 2/3 to
 10/100/1000 Ethernet device driver
Date: Sun, 26 Jul 2015 16:42:17 -0700 (PDT)
Message-ID: <20150726.164217.2175444603653367329.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D530DCF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168AbbGZXmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:42:18 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D530DCF@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Wed, 22 Jul 2015 19:01:44 +0000

> - remove module param which can be configurable by standard mechanism.

You still left some unacceptable module parameters in here.

The only one which is fine is the debug level setting, that's
it.

There is no way in I'm applying a patch that allows programming
registers of the chip directly via module parameters, no way.
