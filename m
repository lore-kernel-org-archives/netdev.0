From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: fix workarround for wap54g10
Date: Wed, 01 Dec 2010 11:12:28 -0800 (PST)
Message-ID: <20101201.111228.102548986.davem@davemloft.net>
References: <1290876463-4372-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755839Ab0LATMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:12:02 -0500
In-Reply-To: <1290876463-4372-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 27 Nov 2010 17:47:43 +0100

> The code for the b44_wap54g10_workaround was never included, because
> the config option was wrong. The nvram_get function was never in
> mainline kernel, only in external OpenWrt patches.
> 
> The code should be compiled in when CONFIG_BCM47XX is selected and not
> when CONFIG_SSB_DRIVER_MIPS is selected, because nvram_getenv is only
> available on bcm47xx platforms and now in the mainline kernel code.
> Using an include is better than a second function declaration, to fix
> this when the function signature changes.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied, thank you.
