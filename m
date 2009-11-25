From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: move PHY regs tables to .rodata
Date: Wed, 25 Nov 2009 15:55:13 -0800 (PST)
Message-ID: <20091125.155513.178802812.davem@davemloft.net>
References: <20091125213933.GA3455@x200.malnet.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965006AbZKYXyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:54:55 -0500
In-Reply-To: <20091125213933.GA3455@x200.malnet.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 26 Nov 2009 00:39:34 +0300

> As side effect, consume less stack.
> 
> 	-rtl8169_get_mac_version [vmlinux]:	432
> 	-rtl8169_init_one [vmlinux]:		376
> 	+rtl8169_init_one [vmlinux]:		136
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

There are a lot of differences in the tables in net-next-2.6's copy
of this driver, so I had to munge this a lot and do some things by
hand to apply it properly.

So, applied... but please always submit networking changes against the
proper tree, thanks.
