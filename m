From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/cpmac.c: Correct code taking the size of a
 pointer
Date: Sun, 13 Dec 2009 19:57:56 -0800 (PST)
Message-ID: <20091213.195756.102569162.davem@davemloft.net>
References: <Pine.LNX.4.64.0912131635110.27767@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756539AbZLND5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:57:54 -0500
In-Reply-To: <Pine.LNX.4.64.0912131635110.27767@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 13 Dec 2009 16:35:45 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> sizeof(dev->dev_addr) is the size of a pointer.  On the other hand,
> sizeof(pdata->dev_addr) is the size of an array, so use that instead.
> 
> A simplified version of the semantic patch that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
