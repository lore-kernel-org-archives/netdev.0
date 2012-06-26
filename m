From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] bridge: Assign rtnl_link_ops to bridge devices created
 via ioctl()
Date: Tue, 26 Jun 2012 11:13:11 -0400
Message-ID: <20120626151311.GB31808@canuck.infradead.org>
References: <692d04316b78401b0256598155caae190d3f27c9.1340700973.git.tgraf@suug.ch>
 <20120626075940.099521a7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:41802 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370Ab2FZPNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 11:13:16 -0400
Content-Disposition: inline
In-Reply-To: <20120626075940.099521a7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 07:59:40AM -0700, Stephen Hemminger wrote:
> On Tue, 26 Jun 2012 10:56:15 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > +void br_assign_rtnl_link_ops(struct net_device *dev)
> > +{
> > +	dev->rtnl_link_ops = &br_link_ops;
> > +}
> 
> I am fine with the concept, but maybe it would just be simpler to
> make br_link_ops public?

Either is fine with me. I chose the assignment function to keep the
struct read-only outside of br_netlink.c.
