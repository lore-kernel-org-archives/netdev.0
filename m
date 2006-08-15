From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/13] constify Tigon3 ether firmware structs
Date: Tue, 15 Aug 2006 00:11:27 -0700 (PDT)
Message-ID: <20060815.001127.01051322.davem@davemloft.net>
References: <200608150603.k7F63jC4012954@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@rhlx01.fht-esslingen.de, andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30644
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965266AbWHOHLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:11:25 -0400
To: akpm@osdl.org
In-Reply-To: <200608150603.k7F63jC4012954@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 14 Aug 2006 23:03:45 -0700

> From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
> 
> Constify largish areas of firmware data in Tigon3 ethernet driver.
> 
> non-const:
> 
> lsmod:
> tg3                   101404  0
> 
> objdump -x:
> .rodata 000003e8
> .data 00004a0c
> 
> ls -l:
> -rw-r--r-- 1 root root 114404 2006-08-19 21:36 drivers/net/tg3.ko
> 
> const:
> 
> lsmod:
> tg3                   101404  0
> 
> objdump -x:
> .rodata 000042c8
> .data 00000b4c
> 
> ls -l:
> -rw-r--r-- 1 root root 114532 2006-08-19 21:06 drivers/net/tg3.ko
> 
> Signed-off-by: Andreas Mohr <andi@lisas.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.19
