From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isa-skelton: Remove a wrong netif_wake_queue() call
Date: Fri, 26 Feb 2010 01:51:38 -0800 (PST)
Message-ID: <20100226.015138.00843007.davem@davemloft.net>
References: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49085
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935745Ab0BZJvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:51:21 -0500
In-Reply-To: <1267027217-7812-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu, 25 Feb 2010 01:00:17 +0900

> The netif_wake_queue() is called correctly (i.e. only on !txfull
> condition) from net_tx().  So Unconditional call to the
> netif_wake_queue() here is wrong.  This might cause calling of
> start_xmit routine on txfull state and trigger tx-ring overflow.
> 
> This fix is ported from commit 662a96bd6f020782dfbdc0d0bd177c7dbb556687.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied.

Please reference commits by also making mention of the commit
log message header line.  This way when a patch is backported
into another tree, people can still find it even if the
SHA1 ID is different.  For exmaple, I fixed the above to
read:

    This fix is ported from commit 662a96bd6f020782dfbdc0d0bd177c7dbb556687
    ("tc35815: Remove a wrong netif_wake_queue() call which triggers BUG_ON").

Thanks.
