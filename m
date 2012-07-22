From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: fix printk format warnings
Date: Sun, 22 Jul 2012 12:18:53 -0700 (PDT)
Message-ID: <20120722.121853.633423475129374712.davem@davemloft.net>
References: <500B170B.4000000@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org,
	inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, akpm@linux-foundation.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2GVTSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:18:54 -0400
In-Reply-To: <500B170B.4000000@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Sat, 21 Jul 2012 13:54:35 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix printk format warnings in drivers/net/wimax/i2400m:
> 
> drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]
> drivers/net/wimax/i2400m/control.c: warning: format '%zu' expects argument of type 'size_t', but argument 5 has type 'ssize_t' [-Wformat]
> drivers/net/wimax/i2400m/usb-fw.c: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'ssize_t' [-Wformat]
> 
> I don't see these warnings on x86.  The warnings that are quoted above
> are from Geert's kernel build reports.
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks Randy.
