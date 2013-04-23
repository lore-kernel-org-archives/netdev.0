From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 15:30:20 +0800
Message-ID: <1366702220.21136.23.camel@cr0>
References: <1366700820-26052-1-git-send-email-amwang@redhat.com>
	 <20130423.031135.166163672665280174.davem@davemloft.net>
	 <1366701302.21136.19.camel@cr0>
	 <20130423.031805.544535198246859192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710Ab3DWHac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 03:30:32 -0400
In-Reply-To: <20130423.031805.544535198246859192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 03:18 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 23 Apr 2013 15:15:02 +0800
> 
> > On Tue, 2013-04-23 at 03:11 -0400, David Miller wrote:
> >> From: Cong Wang <amwang@redhat.com>
> >> Date: Tue, 23 Apr 2013 15:07:00 +0800
> >> 
> >> > From: Cong Wang <amwang@redhat.com>
> >> > 
> >> > They well deserve a separated unit.
> >> > 
> >> > Cc: "David S. Miller" <davem@davemloft.net>
> >> > Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> 
> >> > Signed-off-by: Cong Wang <amwang@redhat.com>
> >> 
> >> Cong, I'm not even reading these patches.
> >> 
> >> You're on this idea that you can just keep the sysfs and procfs bits
> >> of ipv6 modular, and make the rest of ipv6 statically linked into the
> >> kernel.
> > 
> > I am trying that only for mcast.c, not for the whole IPv6.
> 
> The multicast stuff does route lookups, how are you going to
> accomplish this?

This is hard to do, as in the email I replied to Stephen. So I prefer to
just add a Kconfig dependency, at least for now.

> 
> Besides you should move the statically-needed code into a new
> file (mcast_core.c or something like that, following the existing
> model and conventions for doing this) rather than the other way
> around.

Yes, this is half-done and is also why I sent it alone rather than in
the VXLAN series.

Thanks.
