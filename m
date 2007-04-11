From: Esben Nielsen <nielsen.esben@googlemail.com>
Subject: Re: [PATCH 20/30] Use menuconfig objects - ARCNET
Date: Wed, 11 Apr 2007 10:30:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704111014330.13800@frodo.shire>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
 <Pine.LNX.4.61.0704102329540.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:3099 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbXDKIbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 04:31:11 -0400
Received: by ug-out-1314.google.com with SMTP id 44so68214uga
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2007 01:31:09 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.61.0704102329540.32056@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Apr 2007, Jan Engelhardt wrote:

>
> (Wow, not a single MODULE_AUTHOR line in drivers/net/arcnet/ ...)


ArcNet is old. Almost nobody is using it anymore. I used it at my former 
job, since we used it as control network. A lot of companies still does 
quitely, but not in combination with Linux.

>
> Use menuconfigs instead of menus, so the whole menu can be disabled at
> once instead of going through all options.
>
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
>
> Index: linux-2.6.21-rc5/drivers/net/arcnet/Kconfig
> ===================================================================
> --- linux-2.6.21-rc5.orig/drivers/net/arcnet/Kconfig
> +++ linux-2.6.21-rc5/drivers/net/arcnet/Kconfig
> @@ -2,10 +2,8 @@
> # Arcnet configuration
> #
>
> -menu "ARCnet devices"
> +menuconfig ARCNET
> 	depends on NETDEVICES && (ISA || PCI)

Why does it depend on ISA || PCI ? People tend to forget the PCMCIA 
driver. And in principle you could enable the ArcNet framework without 
using any of the drivers in the kernel tree.


Esben

