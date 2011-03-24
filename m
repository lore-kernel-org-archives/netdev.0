From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix pch_gbe section mismatch warning
Date: Thu, 24 Mar 2011 16:16:14 -0700 (PDT)
Message-ID: <20110324.161614.232895368.davem@davemloft.net>
References: <20110324132812.5bd28f51.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toshiharu-linux@dsn.okisemi.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934349Ab1CXXPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 19:15:35 -0400
In-Reply-To: <20110324132812.5bd28f51.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 24 Mar 2011 13:28:12 -0700

> Fix section mismatch warning by renaming the pci_driver variable to a
> recognized (whitelisted) name.
> 
> WARNING: drivers/net/pch_gbe/pch_gbe.o(.data+0x1f8): Section mismatch in reference from the variable pch_gbe_pcidev to the variable .devinit.rodata:pch_gbe_pcidev_id
> The variable pch_gbe_pcidev references
> the variable __devinitconst pch_gbe_pcidev_id
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
