From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: RE: [PATCH] [2.6.17]   Add tsi108 Ethernet device driver support
Date: Tue, 4 Jul 2006 12:47:47 +0800
Message-ID: <9FCDBA58F226D911B202000BDBAD467306F5027F@zch01exm40.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alexandre.Bounine@tundra.com,
	Yang Xin-Xin-r48390 <Xin-Xin.Yang@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:27609 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1750917AbWGDEr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 00:47:56 -0400
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Wed, 21 Jun 2006 12:00:40 +0800
> Zang Roy-r61911 <tie-fei.zang@freescale.com> wrote:
> 
> > This patch adds a net device driver and configuration options for 
> > Tundra Semiconductor Tsi108 integrated dual port Gigabit Ethernet 
> > controller
> 
> Your patch forgot to include these:
> 
> > +#include <asm/tsi108_irq.h>
> > +#include <asm/tsi108.h>
> 
> Why would a net driver have files in include/asm/?

The net driver is for a tsi108 on chip Ethernet controller.  tsi108_irq provides the Ethernet IRQ number.
tsi108.h provides the hw_info structure. Now tsi108.h has been in the kernel tree. I'd like to provide
the tsi108_irq.h with tsi108  irq support in another patch. Any comment? 

> 
> 
> 
> 
> Have some comments-via-diff, mainly trivial:
> 
Thanks for your patch. It works OK! I will integrate it in my next version.
