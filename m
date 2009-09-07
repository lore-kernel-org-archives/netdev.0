From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: remove deprecated PCI_DEVICE_ID from PCI200SYN
 driver.
Date: Mon, 07 Sep 2009 01:58:37 -0700 (PDT)
Message-ID: <20090907.015837.121897315.davem@davemloft.net>
References: <m363byk3af.fsf@intrepid.localdomain>
	<m3ljktek61.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485AbZIGI6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 04:58:21 -0400
In-Reply-To: <m3ljktek61.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 05 Sep 2009 12:54:30 +0200

> PCI200SYN has its own PCI subsystem device ID for 3+ years, now it's
> time to remove the generic PLX905[02] ID from the driver. Anyone with
> old EEPROM data will have to run the upgrade.
> 
> Having the generic PLX905[02] (PCI-local bus bridge) ID is harmful
> as the driver tries to handle other devices based on these bridges.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Applied to net-next-2.6, thanks.
