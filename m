From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: gianfar: add missing __iomem
 annotation
Date: Tue, 30 Dec 2014 19:05:19 -0500 (EST)
Message-ID: <20141230.190519.1196965378794951492.davem@davemloft.net>
References: <1419401145-8967-1-git-send-email-haokexin@gmail.com>
	<1419401145-8967-2-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: haokexin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbaLaAFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 19:05:21 -0500
In-Reply-To: <1419401145-8967-2-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>
Date: Wed, 24 Dec 2014 14:05:45 +0800

> Fix the following spare warning:
> drivers/net/ethernet/freescale/gianfar.c:3521:60: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/ethernet/freescale/gianfar.c:3521:60:    expected unsigned int [noderef] <asn:2>*addr
> drivers/net/ethernet/freescale/gianfar.c:3521:60:    got unsigned int [usertype] *rfbptr
> drivers/net/ethernet/freescale/gianfar.c:205:16: warning: incorrect type in assignment (different address spaces)
> drivers/net/ethernet/freescale/gianfar.c:205:16:    expected unsigned int [usertype] *rfbptr
> drivers/net/ethernet/freescale/gianfar.c:205:16:    got unsigned int [noderef] <asn:2>*<noident>
> drivers/net/ethernet/freescale/gianfar.c:2918:44: warning: incorrect type in argument 1 (different address spaces)
> drivers/net/ethernet/freescale/gianfar.c:2918:44:    expected unsigned int [noderef] <asn:2>*addr
> drivers/net/ethernet/freescale/gianfar.c:2918:44:    got unsigned int [usertype] *rfbptr
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>

Applied.
