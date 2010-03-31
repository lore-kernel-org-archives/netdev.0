From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Wed, 31 Mar 2010 16:08:11 -0700
Message-ID: <20100331160811.16351eb7@s6510>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	<20100330161746.9628.40723.stgit@bert.katalix.com>
	<20100330092914.4f3e9ed3@nehalam>
	<4BB2FD0D.1080105@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56442 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590Ab0CaXIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 19:08:13 -0400
In-Reply-To: <4BB2FD0D.1080105@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Mar 2010 08:43:09 +0100
James Chapman <jchapman@katalix.com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 30 Mar 2010 17:17:46 +0100
> > James Chapman <jchapman@katalix.com> wrote:
> > 
> >> When dumping L2TP PPP sessions using /proc/net/l2tp, get
> >> the assigned PPP device name from PPP using ppp_dev_name().
> >>
> >> Signed-off-by: James Chapman <jchapman@katalix.com>
> >> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
> >>
> > 
> > Why is this a necessary API?
> > Why not put it in debugfs if just a debugging tool?
> 
> With the original driver (merged in 2.6.23), some people use horrible
> hacks in scripts to derive info about their L2TP connections from /proc.
> So I was reluctant to move it to debugfs in the new driver. If it is ok
> to move an existing /proc file to debugfs, I'm happy to do so. People
> should obtain such info from their L2TP userspace daemon, or through
> netlink anyway.
> 
> 


Sounds like a good use of sysfs either with attribute or symlink
back to underlying device
