From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] decnet: Parse netlink attributes on our own
Date: Fri, 22 Mar 2013 14:27:35 +0000
Message-ID: <20130322142735.GA11368@casper.infradead.org>
References: <cover.1363885020.git.tgraf@suug.ch>
 <5b888618a6aebfebf496c91482794a606b3bb094.1363885020.git.tgraf@suug.ch>
 <1363889099.2707.14.camel@menhir>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59570 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605Ab3CVO1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:27:39 -0400
Content-Disposition: inline
In-Reply-To: <1363889099.2707.14.camel@menhir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/13 at 06:04pm, Steven Whitehouse wrote:
> You shouldn't need any special hardware to test this. A copy of iproute2
> should be enough as you should be able to use that to create an
> interface or two and a route between them, etc. Although DECnet routing
> works in a different way to ip routing, the Linux implementation tries
> to stick fairly closely to the ip way of doing things whenever it can in
> order to share infrastructure. Now that ip has diverged a fair bit over
> time that isn't quite as true as it was, but there shouldn't be anything
> too surprising in there.

Alright, I did some basic testing with iproute2. I do not claim
to understand what I did but I ran the following:

$ ip -f dnet route add 1.661 dev em1
$ ip -f dnet route list
1.661 dev em1  scope link

$ ip -f dnet neigh add 6.662 dev em1
$ ip -f dnet neigh list
6.662 dev em1 lladdr aa:00:04:00:96:1a PERMANENT

$ ip -f dnet addr add 1.111 dev em1
$ ip -f dnet addr list
2: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    dnet 1.111/16 scope global em1
