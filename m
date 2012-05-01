From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 1 May 2012 09:59:38 -0700
Message-ID: <20120501095938.7214e4a5@s6510.linuxnetplumber.net>
References: <1335863465.11396.45.camel@edumazet-glaptop>
	<20120501.094051.655617860554790911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, hagen@jauu.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55776 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169Ab2EAQ7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 12:59:47 -0400
In-Reply-To: <20120501.094051.655617860554790911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 May 2012 09:40:51 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 01 May 2012 11:11:05 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Add ECN (Explicit Congestion Notification) marking capability to netem
> > 
> > tc qdisc add dev eth0 root netem drop 0.5 ecn
> > 
> > Instead of dropping packets, try to ECN mark them.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

At least give a day of review, rather than premature acceptance
