From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 16:28:41 -0500 (EST)
Message-ID: <20151222.162841.889225793486693960.davem@davemloft.net>
References: <CAEfhGiwEhWqwtbAhbaVCEohePUyUC+f-Ap6b4oHk1Mdkg+ZKUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbbLVV2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:28:43 -0500
In-Reply-To: <CAEfhGiwEhWqwtbAhbaVCEohePUyUC+f-Ap6b4oHk1Mdkg+ZKUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 22 Dec 2015 15:51:19 -0500

> I was actually just looking at this as well (though a slightly
> different stack).  The issue is with: c6ff5268293e rhashtable: Fix
> walker list corruption
> 
> It changed the lock acquired in rhashtable_walk_init to use the new
> spinlock, but the rht_dereference macro expects the mutex.  I was
> still trying to track down which repository this change came in
> through, though...

Both cam via my networking tree.
