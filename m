From: David Miller <davem@davemloft.net>
Subject: Re: [Lksctp-developers] [PATCH][SCTP]: Pick up an orphaned
 sctp_sockets_allocated counter.
Date: Wed, 20 Feb 2008 00:23:19 -0800 (PST)
Message-ID: <20080220.002319.130915234.davem@davemloft.net>
References: <47BB05AA.6090101@openvz.org>
	<47BB0740.2070104@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753099AbYBTIWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:22:42 -0500
In-Reply-To: <47BB0740.2070104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 19 Feb 2008 11:43:44 -0500

> Pavel Emelyanov wrote:
> > This counter is currently write-only.
> > 
> > Drawing an analogy with the similar tcp counter, I think
> > that this one should be pointed by the sockets_allocated
> > members of sctp_prot and sctpv6_prot.
> > 
> > Or should it be instead removed at all?
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Ack.  Looks like it got missed.  It should be added.

Applied, thanks everyone.
