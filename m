From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Fix portabilty issues for ethtool
 and ptp
Date: Wed, 15 Jan 2014 14:39:54 -0800 (PST)
Message-ID: <20140115.143954.1643141626782262450.davem@davemloft.net>
References: <1389706500-1990-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbaAOWj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 17:39:56 -0500
In-Reply-To: <1389706500-1990-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 14 Jan 2014 15:35:00 +0200

> Fixes unhandled register write in gianfar_ethtool.c.
> Fixes following endianess related functional issues,
> reported by sparse as well, i.e.:
> 
> gianfar_ethtool.c:1058:33: warning:
>     incorrect type in argument 1 (different base types)
>     expected unsigned int [unsigned] [usertype] value
>     got restricted __be32 [usertype] ip4src
> 
> gianfar_ethtool.c:1164:33: warning:
>     restricted __be16 degrades to integer
> 
> gianfar_ethtool.c:1669:32: warning:
>     invalid assignment: ^=
>     left side has type restricted __be16
>     right side has type int
> 
> Solves all the sparse warnings for mixig normal pointers
> with __iomem pointers for gianfar_ptp.c, i.e.:
> gianfar_ptp.c:163:32: warning:
>     incorrect type in argument 1 (different address spaces)
>     expected unsigned int [noderef] <asn:2>*addr
>     got unsigned int *<noident>
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thank you.
