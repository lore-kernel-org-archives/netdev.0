From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] mv643xx_eth fixes for 2.6.30
Date: Wed, 29 Apr 2009 17:24:54 -0700 (PDT)
Message-ID: <20090429.172454.88395298.davem@davemloft.net>
References: <20090429215625.GY14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbZD3AZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:25:00 -0400
In-Reply-To: <20090429215625.GY14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 29 Apr 2009 23:56:25 +0200

> Two more fixes for mv643xx_eth for 2.6.30:
> 1. Fix OOM handling, mv643xx_eth will currently just get into an
>    infinite netdev_alloc_skb() loop on OOM due to a logic bug.
> 2. Fix problem where hardware 64bit MIB counters are actually 32bit
>    (and reads from the upper and lower halves have the same effect),
>    which can cause the software stats counters to spuriously increment
>    by some multiple of 2^32 if a packet comes in at the right moment.
> 
> Since these should also go into 2.6.29.X, I added "Cc: stable@kernel.org"
> on both.
> 
> Please apply, thanks!

Applied and queued up for -stable, thanks!
