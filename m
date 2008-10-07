From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/32] net: wrap sk->sk_backlog_rcv()
Date: Tue, 07 Oct 2008 14:19:02 -0700 (PDT)
Message-ID: <20081007.141902.06048204.davem@davemloft.net>
References: <20081002130504.927878499@chello.nl>
	<20081002131608.667433428@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757548AbYJGVT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:19:27 -0400
In-Reply-To: <20081002131608.667433428@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:20 +0200

> Wrap calling sk->sk_backlog_rcv() in a function. This will allow extending the
> generic sk_backlog_rcv behaviour.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks fine, applied to net-next-2.6, thanks!
