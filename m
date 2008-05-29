From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [ipv6] Odd behaviour...
Date: Thu, 29 May 2008 01:51:31 -0700
Message-ID: <20080529015131.da6bdcfb.akpm@linux-foundation.org>
References: <1211842711.8367.11.camel@localhost>
	<20080529002729.d87fed29.akpm@linux-foundation.org>
	<20080529084157.GD11812@pomac.netswarm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-kernel <Linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34967 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753684AbYE2IwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:52:16 -0400
In-Reply-To: <20080529084157.GD11812@pomac.netswarm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2008 10:41:57 +0200 pomac@vapor.com wrote:

> On Thu, May 29, 2008 at 12:27:29AM -0700, Andrew Morton wrote:
> > On Tue, 27 May 2008 00:58:30 +0200 Ian Kumlien <pomac@vapor.com> wrote:
> > 
> > > Hi, 
> > > 
> > > I just recently acquired a new ipv6 tunnel since my two previous brokers
> > > has gone out of business. I now use hurricane electrics tunnel since i
> > > have really good ping times to it's node in Amsterdam.
> > > 
> > > Anyways, i have setup a local network tunnel and enabled forwarding.
> > > 
> > > After about 300 seconds, it all stops working. I have to disable and
> > > re-enable it on the firewall/router to get it working again.
> > > 
> > > tcpdump shows the router/firewall doing odd things like:
> > > (i renamed my host to piv6)
> > > 
> > > 00:48:14.294173 IP6 piv6 > igloo.stacken.kth.se: ICMP6, echo request,
> > > seq 321, length 64
> > > 
> > > 00:48:14.341288 IP6 igloo.stacken.kth.se > piv6: ICMP6, echo reply, seq
> > > 321, length 64
> > > 
> > > 00:48:14.341317 IP6 fe80::55e4:1b90 > igloo.stacken.kth.se: ICMP6,
> > > redirect, piv6 to piv6, length 160
> > > 
> > > 00:48:14.341332 IP6 igloo.stacken.kth.se > piv6: ICMP6, echo reply, seq
> > > 321, length 64
> > > ---
> > > 
> > > fe80::55e4::1b90 is the local ip of the ipv6 tunnel.
> > > (note: the packet never arrives at it's destination)
> > > 
> > > Any ideas of what could be going wrong?			
> > 
> > (cc netdev - afaik linux-net is kind of dead)
> 
> Thanks, i knew i missed something, -net was the one that was already in
> my email client so... =)

Yeah.  linux-net _might_ be a hive of activity, dunno.  I haven't been
there in years.  Perhaps it should be retired.

> > What kernel version are you running?
> 
> The router/fw is running 2.6.25.1, the client is running 2.6.25.4
> 
> Any additional information i should provide?

It would be interesting if you know of any earlier kernel version which
works OK?

