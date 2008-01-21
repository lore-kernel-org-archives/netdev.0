From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Mon, 21 Jan 2008 02:28:21 -0800 (PST)
Message-ID: <20080121.022821.56278182.davem@davemloft.net>
References: <20080120152146.70bc0b12@deepthought>
	<20080121050355.GD7541@linux.vnet.ibm.com>
	<479449DC.4020105@freedesktop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: josh@freedesktop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758337AbYAUK2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:28:16 -0500
In-Reply-To: <479449DC.4020105@freedesktop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Triplett <josh@freedesktop.org>
Date: Sun, 20 Jan 2008 23:29:32 -0800

> At the moment, Sparse doesn't actually use the context expression.  In
> the ideal case when it does, all references to the same lock should
> use a context expression which resolves to that lock (whatever that
> may mean; hence why Sparse doesn't handle it yet).  For mechanisms
> like RCU without a lock variable, this will likely entail some sort of
> fake lock expression, which again needs to match between all users of
> the same mechanism.  Like any expression in C, case matters; thus,
> please match the existing references to "RCU" rather than "rcu".

Thus, I've checked in Stephen's patch with __acquires(RCU) and
__releases(RCU).

Thanks.

