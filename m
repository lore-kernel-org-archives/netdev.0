From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Tue, 15 May 2012 21:22:15 +0000
Message-ID: <201205152122.15840.arnd@arndb.de>
References: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:49177 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966208Ab2EOVWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 17:22:21 -0400
In-Reply-To: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 May 2012, Jaccon Bastiaansen wrote:
> 
> The use of the inw/outw functions by the cs89x0 platform driver
> results in NULL pointer references on ARM platforms and
> platforms that do not provide ISA-style programmed I/O accessors.
> 
> Using inw/outw also accesses the wrong address space on platforms
> that have a PCI I/O space that is not identity-mapped into the
> physical address space.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

Looks good to me now.

Acked-by: Arnd Bergmann <arnd@arndb.de>

Of course we would need some testing on another platform and ideally
also on an ISA based machine, although that might be hard to
come by these days...

	Arnd
