From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [ipv6] Odd behaviour...
Date: Thu, 29 May 2008 18:28:53 +0900 (JST)
Message-ID: <20080529.182853.67833046.yoshfuji@linux-ipv6.org>
References: <1211842711.8367.11.camel@localhost>
	<20080529002729.d87fed29.akpm@linux-foundation.org>
	<20080529084157.GD11812@pomac.netswarm.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53559 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbYE2J2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 05:28:21 -0400
In-Reply-To: <20080529084157.GD11812@pomac.netswarm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080529084157.GD11812@pomac.netswarm.net> (at Thu, 29 May 2008 10:41:57 +0200), pomac@vapor.com says:

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
> 
> > What kernel version are you running?
> 
> The router/fw is running 2.6.25.1, the client is running 2.6.25.4
> 
> Any additional information i should provide?

How do you assign the address?

--yoshfuji
