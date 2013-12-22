From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Sun, 22 Dec 2013 04:10:03 +0100
Message-ID: <20131222031003.GI14073@order.stressinduktion.org>
References: <20131219162810.55810@gmx.com> <1387473858.19078.362.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45298 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab3LVDKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 22:10:05 -0500
Content-Disposition: inline
In-Reply-To: <1387473858.19078.362.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 09:24:18AM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-19 at 17:28 +0100, Bob Falken wrote:
> > The only reason why i give information about 2.6.36.4 is that its the
> > only latest kernel that was functioning properly.
> > i.e kernel >= 2.6.37 is not woking. so its a bisecting of the kernel
> > versions to help a coder see when/where the isse was implemented in
> > the kernel.
> > 
> > I do not need a backport patch for an old kernel, I generally only
> > need the issue looked into and get fixed so that I dont have to use an
> > old kernel. :)
> > 
> > I have no issue reproducing the issue on the recent kernels. however i
> > have not tried the GIT kernel.
> > 
> > I restarted the server just a moment ago. i will install and run
> > dropwatch and provide feedback in about 17hours. 
> 
> You said that "cat /proc/net/ip_mr_cache" gives nothing at all after
> 2^32 packets ?
> 
> Thats a bit scary ... maybe a 32bit refcnt overflow, because of some
> imbalance...

I have the feeling it may have something to do with FIB_LOOKUP_NOREF. More
tomorrow...

Greetings,

  Hannes
