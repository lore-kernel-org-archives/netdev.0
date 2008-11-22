From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next/-mm/mainline] net/hp-plus: fix link errors
Date: Fri, 21 Nov 2008 16:33:35 -0800 (PST)
Message-ID: <20081121.163335.255948683.davem@davemloft.net>
References: <20081120211724.09b94026.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751989AbYKVAdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:33:36 -0500
In-Reply-To: <20081120211724.09b94026.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 20 Nov 2008 21:17:24 -0800

> Fix hp-plus driver link errors.
> Builds as loadable module and kernel image driver.
> All drivers that use 8390.o or 8390p.o that will build on
> i386 with MCA/PCI/EISA/ISA were built successfully both
> =m and =y.
> 
> drivers/built-in.o: In function `hpp_open':
> hp-plus.c:(.text+0xac06c): undefined reference to `eip_interrupt'
> hp-plus.c:(.text+0xac0d7): undefined reference to `eip_open'
> drivers/built-in.o: In function `hpp_close':
> hp-plus.c:(.text+0xac1bb): undefined reference to `eip_close'
> drivers/built-in.o: In function `hpp_probe1':
> hp-plus.c:(.init.text+0xa98a): undefined reference to `NS8390p_init'
> drivers/built-in.o: In function `hp_plus_probe':
> (.init.text+0xa9fe): undefined reference to `__alloc_eip_netdev'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
