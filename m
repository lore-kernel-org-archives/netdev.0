From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter : xt_hashlimit should use time_after_eq()
Date: Wed, 12 Dec 2007 11:11:43 -0800 (PST)
Message-ID: <20071212.111143.259694887.davem@davemloft.net>
References: <47602AE6.6060908@cosmosbay.com>
	<47603147.90008@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750773AbXLLTLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:11:43 -0500
In-Reply-To: <47603147.90008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 12 Dec 2007 20:06:47 +0100

> Eric Dumazet wrote:
> > Hi David & Patrick
> > 
> > I believe this patch is needed for linux-2.6.24
> > 
> > Thank you
> > 
> > [PATCH] netfilter : xt_hashlimit should use time_after_eq()
> > 
> > In order to avoid jiffies wraparound and its effect, special care must 
> > be taken
> > when doing comparisons ...
> 
> 
> Looks good, thanks Eric. Dave, please apply.

Applied, thanks.
