From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/dnet.c needs <linux/io.h>
Date: Tue, 24 Mar 2009 13:19:59 -0700 (PDT)
Message-ID: <20090324.131959.233890622.davem@davemloft.net>
References: <Pine.LNX.4.64.0903242042060.19647@anakin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanok@emcraft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753951AbZCXUUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 16:20:12 -0400
In-Reply-To: <Pine.LNX.4.64.0903242042060.19647@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 24 Mar 2009 20:43:25 +0100 (CET)

> On m68k:
> | drivers/net/dnet.c: In function 'dnet_readw_mac':
> | drivers/net/dnet.c:36: error: implicit declaration of function 'writel'
> | drivers/net/dnet.c:43: error: implicit declaration of function 'readl'
> | drivers/net/dnet.c: In function 'dnet_probe':
> | drivers/net/dnet.c:873: error: implicit declaration of function 'ioremap'
> | drivers/net/dnet.c:873: warning: assignment makes pointer from integer without a cast
> | drivers/net/dnet.c:939: error: implicit declaration of function 'iounmap'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks!
