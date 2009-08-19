From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yellowfin: Fix buffer underrun after dev_alloc_skb()
 failure
Date: Tue, 18 Aug 2009 20:21:49 -0700 (PDT)
Message-ID: <20090818.202149.245453512.davem@davemloft.net>
References: <4A853572.70209@gmail.com>
	<20090814.161701.02803885.davem@davemloft.net>
	<4A8A6B5A.7030104@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751937AbZHSDVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 23:21:38 -0400
In-Reply-To: <4A8A6B5A.7030104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 18 Aug 2009 10:50:34 +0200

> yellowfin_init_ring() needs to clean up if dev_alloc_skb() fails and
> should pass an error status up to the caller. This also prevents an
> buffer underrun if failure occurred in the first iteration.
> yellowfin_open() which calls yellowfin_init_ring() should free its
> requested irq upon failure.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Looks good, applied, thanks.
