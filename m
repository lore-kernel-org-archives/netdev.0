From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Fri, 3 Jan 2014 08:37:19 +0100
Message-ID: <20140103073719.GN22494@order.stressinduktion.org>
References: <20131221223501.110860@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36763 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbaACHhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 02:37:20 -0500
Content-Disposition: inline
In-Reply-To: <20131221223501.110860@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 21, 2013 at 11:35:00PM +0100, Bob Falken wrote:
>  On Thu, Dec 19, 2013 at 09:24:18AM -0800, Eric Dumazet wrote:
> > On Thu, 2013-12-19 at 17:28 +0100, Bob Falken wrote:
> > > The only reason why i give information about 2.6.36.4 is that its the
> > > only latest kernel that was functioning properly.
> > > i.e kernel >= 2.6.37 is not woking. so its a bisecting of the kernel
> > > versions to help a coder see when/where the isse was implemented in
> > > the kernel.
> > > 
> > > I do not need a backport patch for an old kernel, I generally only
> > > need the issue looked into and get fixed so that I dont have to use an
> > > old kernel. :)
> > > 
> > > I have no issue reproducing the issue on the recent kernels. however i
> > > have not tried the GIT kernel.
> > > 
> > > I restarted the server just a moment ago. i will install and run
> > > dropwatch and provide feedback in about 17hours. 
> > 
> > You said that "cat /proc/net/ip_mr_cache" gives nothing at all after
> > 2^32 packets ?
> > 
> > Thats a bit scary ... maybe a 32bit refcnt overflow, because of some
> > imbalance...
> 
> That's my thought, too. :/
> 
> The ipmr.c rcu conversion happend in 2.6.37. 
> 

Just as a follow-up. You could verify if we actually have a refcount overflow
if you try a grsec kernel with PAX_REFCOUNT enabled. If a refcoount overflow
happens, dmesg should show then.

Greetings,

  Hannes
