From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Fix build failure with gcc 3.2
Date: Mon, 03 Aug 2009 21:10:16 -0700 (PDT)
Message-ID: <20090803.211016.21222287.davem@davemloft.net>
References: <20090803134803.3c8a0159@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	a.beregalov@gmail.com
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46437
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750860AbZHDEKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 00:10:08 -0400
In-Reply-To: <20090803134803.3c8a0159@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>
Date: Mon, 3 Aug 2009 13:48:03 +0200

> Fix the following build failure with gcc 3.2:
> 
>   CC [M]  drivers/net/3c59x.o
> drivers/net/3c59x.c:2726:1: directives may not be used inside a macro argument
> drivers/net/3c59x.c:2725:59: unterminated argument list invoking macro "pr_err"
> drivers/net/3c59x.c: In function `dump_tx_ring':
> drivers/net/3c59x.c:2727: implicit declaration of function `pr_err'
> drivers/net/3c59x.c:2731: syntax error before ')' token
> 
> Apparently gcc 3.2 doesn't like #if interleaved with a macro call.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>

Applied, thanks.
