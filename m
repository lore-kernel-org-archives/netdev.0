From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove useless prefetch() call
Date: Sat, 21 Mar 2009 13:43:10 -0700 (PDT)
Message-ID: <20090321.134310.200703901.davem@davemloft.net>
References: <20090320.013611.67498837.davem@davemloft.net>
	<49C36570.4010903@cosmosbay.com>
	<49C36AE5.6040807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753750AbZCUUnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:43:23 -0400
In-Reply-To: <49C36AE5.6040807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 20 Mar 2009 11:07:33 +0100

> So first patch is OK, what about this updated Changelog ?
> 
> [PATCH] net: remove useless prefetch() call
> 
> There is no gain using prefetch() in dev_hard_start_xmit(), since
> we already had to read ops->ndo_select_queue pointer in dev_pick_tx(),
> and both pointers are probably located in the same cache line.
> 
> This prefetch call slows down fast path because of a stall in address
> computation.

Applied, thanks.
