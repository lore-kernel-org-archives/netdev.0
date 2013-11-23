From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fw: [Bug 65261] New: Packet loss or excessive packet delay repeatedly for some seconds
Date: Sat, 23 Nov 2013 23:17:09 +0100
Message-ID: <20131123221709.GF15822@order.stressinduktion.org>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net> <20131123043359.GC15822@order.stressinduktion.org> <20131123121140.GB28775@tansi.org> <1385225158.20467.70.camel@deadeye.wl.decadent.org.uk> <20131123202046.GB715@tansi.org> <20131123203933.GE15822@order.stressinduktion.org> <20131123215959.GA2570@tansi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Arno Wagner <arno@wagner.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33481 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708Ab3KWWRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:17:11 -0500
Content-Disposition: inline
In-Reply-To: <20131123215959.GA2570@tansi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 23, 2013 at 11:00:00PM +0100, Arno Wagner wrote:
> On Sat, Nov 23, 2013 at 21:39:33 CET, Hannes Frederic Sowa wrote:
> > On Sat, Nov 23, 2013 at 09:20:47PM +0100, Arno Wagner wrote:
> > > On Sat, Nov 23, 2013 at 17:45:58 CET, Ben Hutchings wrote:
> > > > On Sat, 2013-11-23 at 13:11 +0100, Arno Wagner wrote:
> > > > > On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
> > > > [...]
> > > > > > Could you try dropwatch while the packet drops are happening?
> > > > > > Often it is helpful to check ip monitor all if events happen during bursty
> > > > > > losses.
> > > > > 
> > > > > Sorry, but dropwatch is not in Debian and compiling it from sources
> > > > > seem to require something called "rpmbuild". Hence I cannot use
> > > > > it or at least would have to write my own Makefile for it. 
> > > > 
> > > > You could use 'perf script net_dropmonitor' instead.
> > > 
> > > That gets me "invalid or unsupported event: 'skb:kfree_skb'"
> > > with 3.10.17, so I guess it will not work with 3.10.19 either.
> > 
> > You need CONFIG_DROP_MONITOR enabled on your kernel build.
> 
> Interestingly, that option is not even there in .config. 
> Must be someting that "make oldconfig" messed up along 
> the way, as making a new .config with all default values 
> does have it commented out as "not set".
> 
> After a bit of poking around, I found it and its pre-requisites 
> net/Kconfig, where it says it depends on INET && TRACEPOINTS.
> After a bit more poking I finally found TRACEPOINTS on init/Kconfig,
> depending on nothing. But it does not get displayed as selectable
> in "make menuconfig".  As far as I can tell, it is not constrained
> and should show up? 
> 
> So I really have no clue how to turn this on...

Check Kernel Hacking -> Tracers. It should show up Networking options ->
Network testing.

Greetings,

  Hannes
