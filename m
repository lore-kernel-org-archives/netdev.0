From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 14:04:54 -0700
Message-ID: <20120620140454.36847c65@s6510.linuxnetplumber.net>
References: <1340171940.4604.799.camel@edumazet-glaptop>
	<1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
	<1340217604.4604.1569.camel@edumazet-glaptop>
	<20120620.140121.1603737472432326278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34589 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696Ab2FTVE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 17:04:57 -0400
In-Reply-To: <20120620.140121.1603737472432326278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jun 2012 14:01:21 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Jun 2012 20:40:04 +0200
> 
> > If someone wants to tune its linux router, he probably already disables
> > GRO because of various issues with too big packets.
> > 
> > GRO adds a significant cost to forwarding path.
> 
> No, Ben is right Eric.  GRO decreases the costs, because it means we
> only need to make one forwarding/netfilter/classification decision for
> N packets instead of 1.

GRO is also important for routers that interact with VM's.
It helps reduce the per-packet wakeup of the guest VM's.
