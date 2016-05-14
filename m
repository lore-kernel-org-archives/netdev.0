From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab
 name
Date: Sat, 14 May 2016 15:16:55 -0400 (EDT)
Message-ID: <20160514.151655.2019278235704717198.davem@davemloft.net>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, w@1wt.eu, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbcENTQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 15:16:57 -0400
In-Reply-To: <alpine.LFD.2.20.1605141116100.24646@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 May 2016 11:24:08 -0700 (PDT)

> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 14 May 2016 11:11:44 -0700
> Subject: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
> 
> The slab name ends up being visible in the directory structure under
> /sys, and even if you don't have access rights to the file you can see
> the filenames.
> 
> Just use a 64-bit counter instead of the pointer to the 'net' structure
> to generate a unique name.
> 
> This code will go away in 4.7 when the conntrack code moves to a single
> kmemcache, but this is the backportable simple solution to avoiding
> leaking kernel pointers to user space.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: stable@vger.kernel.org

Applied, thanks.
