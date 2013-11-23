From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fw: [Bug 65261] New: Packet loss or excessive packet delay repeatedly for some seconds
Date: Sat, 23 Nov 2013 21:39:33 +0100
Message-ID: <20131123203933.GE15822@order.stressinduktion.org>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net> <20131123043359.GC15822@order.stressinduktion.org> <20131123121140.GB28775@tansi.org> <1385225158.20467.70.camel@deadeye.wl.decadent.org.uk> <20131123202046.GB715@tansi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Arno Wagner <arno@wagner.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33352 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854Ab3KWUje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 15:39:34 -0500
Content-Disposition: inline
In-Reply-To: <20131123202046.GB715@tansi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 23, 2013 at 09:20:47PM +0100, Arno Wagner wrote:
> On Sat, Nov 23, 2013 at 17:45:58 CET, Ben Hutchings wrote:
> > On Sat, 2013-11-23 at 13:11 +0100, Arno Wagner wrote:
> > > On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
> > [...]
> > > > Could you try dropwatch while the packet drops are happening?
> > > > Often it is helpful to check ip monitor all if events happen during bursty
> > > > losses.
> > > 
> > > Sorry, but dropwatch is not in Debian and compiling it from sources
> > > seem to require something called "rpmbuild". Hence I cannot use
> > > it or at least would have to write my own Makefile for it. 
> > 
> > You could use 'perf script net_dropmonitor' instead.
> 
> That gets me "invalid or unsupported event: 'skb:kfree_skb'"
> with 3.10.17, so I guess it will not work with 3.10.19 either.

You need CONFIG_DROP_MONITOR enabled on your kernel build.
