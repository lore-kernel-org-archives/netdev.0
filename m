From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/24] net, diet: Make packet tpacket/mmap/fanout/rings
 optional
Date: Mon, 05 May 2014 23:09:25 -0400 (EDT)
Message-ID: <20140505.230925.403754888653633720.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-22-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731AbaEFDJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:09:27 -0400
In-Reply-To: <1399328773-6531-22-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:10 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Many DHCP clients need basic packet sockets, but they don't need
> the fancy zero copy packet capture code, like tpacket, mmap, rings,
> fanouts. This is quite substantial code, so it's worthwhile to
> make it optional
> 
> Worth nearly 10k code.
> 
>    text	   data	    bss	    dec	    hex	filename
>  952827	  71874	  25352	1050053	 1005c5	net/built-in.o-with-packet-mmap
>  943211	  71810	  25352	1040373	  fdff5	net/built-in.o-wo-packet-mmap
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Sorry, I'm not applying this either.

Small systems use packet generation and reception tools commonly, and
the only sane way to do so is with tpacket.
