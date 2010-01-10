From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/next] mac8390: Fix build breakage
Date: Sat, 09 Jan 2010 23:00:39 -0800 (PST)
Message-ID: <20100109.230039.01036685.davem@davemloft.net>
References: <alpine.DEB.2.00.1001091420080.21892@ayla.of.borg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-next@vger.kernel.org, netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751495Ab0AJHAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 02:00:32 -0500
In-Reply-To: <alpine.DEB.2.00.1001091420080.21892@ayla.of.borg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 9 Jan 2010 14:21:28 +0100 (CET)

> commit 18c0019102228875cb0f6f252dad5148491e96b2 ("drivers/net/mac8390.c:
> Convert printk(KERN_<level> to pr_<level>(") broke the build:
> 
> | drivers/net/mac8390.c:306: error: expected ')' before 'version'
> 
> as "version" is not a string literal, but a variable.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks.
