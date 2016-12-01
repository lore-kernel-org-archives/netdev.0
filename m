From: David Miller <davem@davemloft.net>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 01 Dec 2016 11:19:47 -0500 (EST)
Message-ID: <20161201.111947.888676978252329124.davem@davemloft.net>
References: <20161201091108.GF26507@breakpoint.cc>
        <20161201145834.GA569@pox.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbcLAQTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:19:49 -0500
In-Reply-To: <20161201145834.GA569@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 1 Dec 2016 15:58:34 +0100

> The benefits of XDP for this use case are extremely obvious in combination
> with local applications which need to be protected. ntuple filters won't
> cut it. They are limited and subject to a certain rate at which they
> can be configured. Any serious mitigation will require stateful filtering
> with at least minimal L7 matching abilities and this is exactly where XDP
> will excel.

+1

Saying that ntuple filters can handle the early drop use case doesn't
take into consideration the nature of the tables (hundreds of
thousands of "evil" IP addresses), whether hardware can actually
handle that (it can't), and whether simple IP address matching is the
full extent of it (it isn't).

Most of the time when I hear anti-XDP rhetoric, it's usually comes
from a crowd who for some reason feels threatened by the technology
and what it might replace and make useless.

That to me says that we are _exactly_ going down the right path.
