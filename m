From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [patch 08/13] Use menuconfig objects II - netdev (general+100mbit)
Date: Fri, 11 May 2007 23:32:08 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0705112331440.9570@yvahk01.tjqt.qr>
References: <200705110552.l4B5quBQ007813@shell0.pdx.osdl.net>
 <4644D8D0.3080602@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer.gwdg.de ([134.76.10.26]:39677 "EHLO mailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754972AbXEKVc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 17:32:59 -0400
In-Reply-To: <4644D8D0.3080602@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 11 2007 16:57, Jeff Garzik wrote:
>> 
>> CONFIG_NETDEVICES, CONFIG_NET_ETHERNET:
>> Change Kconfig objects from "menu, config" into "menuconfig" so
>> that the user can disable the whole feature without having to
>> enter the menu first.
>> 
>> CONFIG_SMC9194:
>> Move it so that it appears correctly in menuconfig.
>> 
>> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
>> Cc: Jeff Garzik <jeff@garzik.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>> 
>> drivers/net/Kconfig         |  167 ++++++++++++++++------------------
>> drivers/net/arm/Kconfig     |   12 +-
>> drivers/net/fec_8xx/Kconfig |    2 drivers/net/fs_enet/Kconfig |    2
>> drivers/net/tulip/Kconfig   |   27 ++---
>> 5 files changed, 102 insertions(+), 108 deletions(-)
>
> ACK, but failed to apply
>
Name the tree that I should rebase it on. (Did not seem like basing
everything on -mm always works out.)

	Jan
-- 
