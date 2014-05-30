From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: Fix 64 bit divide on 32bit system
Date: Fri, 30 May 2014 15:55:07 -0700 (PDT)
Message-ID: <20140530.155507.1498570358622128968.davem@davemloft.net>
References: <1401099763-2427-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, David.Laight@aculab.com,
	gvaradar@cisco.com, benve@cisco.com, ssujith@cisco.com,
	neepatel@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058AbaE3WzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:55:08 -0400
In-Reply-To: <1401099763-2427-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Mon, 26 May 2014 15:52:43 +0530

> Division of a 32 bit number by a 64 bit number causes the following link
> error introduced by
> 7c2ce6e60f703 "enic: Add support for adaptive interrupt coalescing"
> 
> drivers/built-in.o: In function `enic_poll_msix':
> enic_main.c:(.text+0x48710a): undefined reference to `__udivdi3'
> make: *** [vmlinux] Error 1
> 
> Since numerator is 32 bit, convert denominator to 32 bit accordingly.
> 
> Fixes: 7c2ce6e60f703 ("enic: Add support for adaptive interrupt coalescing")
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Sujith Sankar <ssujith@cisco.com>
> Cc: Neel Patel <neepatel@cisco.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thank you.
