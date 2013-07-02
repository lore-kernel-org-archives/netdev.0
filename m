From: David Miller <davem@davemloft.net>
Subject: Re: fix broken locking in x25 ioctl error paths
Date: Mon, 01 Jul 2013 18:16:38 -0700 (PDT)
Message-ID: <20130701.181638.1716586890151526311.davem@davemloft.net>
References: <20130628151453.GA29428@redhat.com>
	<20130628161352.GA16505@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab3GBBQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 21:16:39 -0400
In-Reply-To: <20130628161352.GA16505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Fri, 28 Jun 2013 12:13:52 -0400

> Two of the x25 ioctl cases have error paths that break out of the function without
> unlocking the socket, leading to this warning:
> 
> ================================================
> [ BUG: lock held when returning to user space! ]
> 3.10.0-rc7+ #36 Not tainted
> ------------------------------------------------
> trinity-child2/31407 is leaving the kernel with locks still held!
> 1 lock held by trinity-child2/31407:
>  #0:  (sk_lock-AF_X25){+.+.+.}, at: [<ffffffffa024b6da>] x25_ioctl+0x8a/0x740 [x25]
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks Dave.

In the future please prefix your patch subject lines with "$subsystem: ", for
this I rewrote it as:

x25: Fix broken locking in ioctl error paths.

Thanks!
