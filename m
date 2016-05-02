From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smscx5xx: use the device tree for mac address
Date: Sun, 01 May 2016 20:58:44 -0400 (EDT)
Message-ID: <20160501.205844.1335479445435999295.davem@davemloft.net>
References: <1461913559-15902-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, steve.glendinning@shawell.net,
	arnd@arndb.de
To: lkundrak@v3.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbcEBA6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 20:58:48 -0400
In-Reply-To: <1461913559-15902-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Fri, 29 Apr 2016 09:05:59 +0200

> From: Arnd Bergmann <arnd@arndb.de>
> 
> This takes the MAC address for smsc75xx/smsc95xx USB network devices
> from a the device tree. This is required to get a usable persistent
> address on the popular beagleboard, whose hardware designers
> accidentally forgot that an ethernet device really requires an a
> MAC address to be functional.
> 
> The Raspberry Pi also ships smsc9514 without a serial EEPROM, stores
> the MAC address in ROM accessible via VC4 firmware.
> 
> The smsc75xx and smsc95xx drivers are just two copies of the
> same code, so better fix both.
> 
> [lkundrak@v3.sk: updated to use of_get_property() as per suggestion from
> Arnd, reworded the message and comments a bit]
> 
> Tested-by: Lubomir Rintel <lkundrak@v3.sk>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied, thanks.
