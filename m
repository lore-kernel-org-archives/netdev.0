From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: fix FEC driver packet transmission breakage
Date: Sun, 09 Aug 2009 21:51:36 -0700 (PDT)
Message-ID: <20090809.215136.256130746.davem@davemloft.net>
References: <200908070358.n773wIxB015388@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org, s.hauer@pengutronix.de
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329AbZHJEv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:51:26 -0400
In-Reply-To: <200908070358.n773wIxB015388@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Fri, 7 Aug 2009 13:58:18 +1000

> fec: fix FEC driver packet transmission breakage
> 
> Commit f0b3fbeae11a526c3d308b691684589ee37c359b 

In the future, when referencing commits, please also provide the
commit message header line text, in parenthesis, and in quotes, like
this ("the commit message header line"), right after the SHA1 ID.

I've fixed up your commit message, in that way, this time.  But
next time I'm going to simply shoot this back to you.

> breaks transmission of
> packets where the skb data buffer is not memory aligned according to
> FEC_ALIGNMENT. It incorrectly passes to dma_sync_single() the buffer
> address directly from the skb, instead of the address calculated for
> use (which may be the skb address or one of the bounce buffers).
> 
> It seems there is no use converting the cpu address of the buffer to
> a physical either, since dma_map_single() expects the cpu address and
> will return the dma address to use in the descriptor. So remove the use
> of __pa() on the buffer address as well.
> 
> This patch is against 2.6.30-rc5. This breakage is a regression over
> 2.6.30, which does not have this problem.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Applied.
