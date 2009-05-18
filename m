From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_teql: should not dereference skb after
 ndo_start_xmit
Date: Mon, 18 May 2009 15:12:56 -0700 (PDT)
Message-ID: <20090518.151256.217066131.davem@davemloft.net>
References: <4A11391D.8060503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753869AbZERWM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:12:59 -0400
In-Reply-To: <4A11391D.8060503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 18 May 2009 12:31:57 +0200

> [PATCH] sch_teql: should not dereference skb after ndo_start_xmit()
> 
> It is illegal to dereference a skb after a successful ndo_start_xmit()
> call. We must store skb length in a local variable instead.
> 
> Bug was introduced in 2.6.27 by commit 0abf77e55a2459aa9905be4b226e4729d5b4f0cb
> (net_sched: Add accessor function for packet length for qdiscs)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied and queued up for -stable, thanks!
