From: David Miller <davem@davemloft.net>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Mon, 12 Mar 2012 23:52:34 -0700 (PDT)
Message-ID: <20120312.235234.73408595516828250.davem@davemloft.net>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
	<20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
	<20120313021529.97514922.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, diego@woitasen.com.ar,
	netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab2CMGwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 02:52:37 -0400
In-Reply-To: <20120313021529.97514922.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 13 Mar 2012 02:15:29 -0400

> Some scripts may depend on this plus its much more efficent that way
> if trying to find a matching route since you can quit on the first
> match instead of having to scan the entire routing table.

No script should be doing stuff like this, let the tool do it for you
via "ip route get ADDR"

There is absolutely no argument for routes to be listed in one order
or another, and anything depending upon order is extremely fragile
and needs to be fixed up anyways.

If you're trying to match something, do a real lookup, a longest
prefix match lookup.  It's the only thing that's going to be correct
all the time, no matter what.
