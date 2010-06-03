From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
Date: Thu, 03 Jun 2010 03:22:29 -0700 (PDT)
Message-ID: <20100603.032229.209599956.davem@davemloft.net>
References: <1275500180-32640-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933555Ab0FCKWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:22:19 -0400
In-Reply-To: <1275500180-32640-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed,  2 Jun 2010 19:36:20 +0200

> commit 5c7fffd0e3b57cb63f50bbd710868f012d67654f ("drivers/net/mac8390.c: Remove
> useless memcpy casting") removed too many casts, introducing the following
> warnings:
> 
> | drivers/net/mac8390.c:248: warning: passing argument 1 of '__builtin_memcpy' makes pointer from integer without a cast
> | drivers/net/mac8390.c:253: warning: passing argument 1 of 'word_memcpy_tocard' makes pointer from integer without a cast
> | drivers/net/mac8390.c:255: warning: passing argument 2 of 'word_memcpy_fromcard' makes pointer from integer without a cast
> 
> Instead of just readding the casts,
>   - move all casts inside word_memcpy_{to,from}card(),
>   - replace an incorrect memcpy() by memcpy_toio(),
>   - add memcmp_withio() as a wrapper around memcmp(),
>   - replace an incorrect memcpy_toio() by memcpy_fromio().
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Tested-by: Finn Thain <fthain@telegraphics.com.au>

Applied.
