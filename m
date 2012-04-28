From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Sat, 28 Apr 2012 05:22:38 -0400 (EDT)
Message-ID: <20120428.052238.1177963256540298198.davem@davemloft.net>
References: <4F9B3980.1080605@intel.com>
	<1335597403.2900.29.camel@edumazet-glaptop>
	<CAKgT0Uc9B0Zrocw=mtb1oS2tHL73tdB4Vj7rKdb7xcikeJxp2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	ncardwell@google.com, therbert@google.com, maze@google.com,
	jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	herbert@gondor.hengli.com.au
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab2D1JXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 05:23:00 -0400
In-Reply-To: <CAKgT0Uc9B0Zrocw=mtb1oS2tHL73tdB4Vj7rKdb7xcikeJxp2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 28 Apr 2012 01:27:24 -0700

> I was thinking there would be a bigger gain with a change like this
> but essentially all you are doing is making the packets more mergable
> resulting in you being able to drop the 256 bytes for the sk_buff in
> either GRO or when it gets queued for the socket.

He's also avoiding the SLUB slow path almost all of the time.
