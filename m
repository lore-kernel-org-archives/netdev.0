From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: drivers/net/ipg.h: remove duplicated #include
Date: Sun, 10 Aug 2008 17:54:34 +0200
Message-ID: <20080810155434.GA31528@electric-eye.fr.zoreil.com>
References: <20080810204944.2EF4.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, jgarzik@redhat.com, netdev@vger.kernel.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58117 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754241AbYHJPzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 11:55:19 -0400
Content-Disposition: inline
In-Reply-To: <20080810204944.2EF4.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Huang Weiyi <weiyi.huang@gmail.com> :
> Removed duplicated include <linux/version.h>
> in drivers/net/ipg.h
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

The driver does not use LINUX_VERSION_CODE nor KERNEL_VERSION.
I would not mind a patch to remove completely the said #include.

It could make some sense for the files below too:

drivers/net/acenic.c
drivers/net/bnx2x_link.c
drivers/net/bnx2x_main.c
drivers/net/cpmac.c
drivers/net/gianfar_sysfs.c
drivers/net/ppp_mppe.c
drivers/net/pppol2tp.c
drivers/net/r6040.c
drivers/net/sh_eth.c
drivers/net/sky2.c
drivers/net/tehuti.h
drivers/net/typhoon.c

Can you take care of those ?

-- 
Ueimor
