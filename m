From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] iproute: Ignore all output fields of ip route get for route add
Date: Fri, 3 Jun 2011 22:52:02 +0200
Message-ID: <20110603205202.GN27166@one.firstfloor.org>
References: <20110603083918.GA15883@one.firstfloor.org> <20110603.020759.797628983600553809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51066 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756135Ab1FCUwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 16:52:03 -0400
Content-Disposition: inline
In-Reply-To: <20110603.020759.797628983600553809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are no guarentees that what the tool outputs for routes is
> suitable for creating routes.
> 
> People have already put vpnc script fixes into Fedora and similar
> already.
> 
> iproute2 is not where the hacks belong.

Hmmm, so you expect every user to maintain the sed line from hell?
Does not sound very user friendly to me.

An alternative would be to add a option to ip route get that disables
printing any options that cannot be used for input.
Would that be more acceptable?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
