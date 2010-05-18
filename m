From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] netdev: bfin_mac: invalid data cache only once for
 each new rx skb buffer
Date: Mon, 17 May 2010 17:21:38 -0700 (PDT)
Message-ID: <20100517.172138.48493572.davem@davemloft.net>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<1273505954-32588-3-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755514Ab0ERAVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:21:30 -0400
In-Reply-To: <1273505954-32588-3-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 May 2010 11:39:08 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> The skb buffer isn't actually used until we finish transferring and pass
> it up to higher layers, so only invalidate the range once before we start
> receiving actual data.  This also avoids the problem with data invalidating
> on Blackfin systems -- there is no invalidate-only, just invalidate+flush.
> So when running in writeback mode, there is the small (but not uncommon)
> possibility of the flush overwriting valid DMA-ed data from the cache.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
