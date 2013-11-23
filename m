From: Arno Wagner <arno@wagner.name>
Subject: Re: Re2: Fw: [Bug 65261] New: Packet loss or excessive packet delay
 repeatedly for some seconds
Date: Sun, 24 Nov 2013 00:01:52 +0100
Message-ID: <20131123230152.GA6835@tansi.org>
References: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net>
 <20131123043359.GC15822@order.stressinduktion.org>
 <20131123121140.GB28775@tansi.org>
 <1385225158.20467.70.camel@deadeye.wl.decadent.org.uk>
 <20131123202046.GB715@tansi.org>
 <20131123203933.GE15822@order.stressinduktion.org>
 <20131123221151.GA6365@tansi.org>
 <20131123221814.GG15822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km31936-01.keymachine.de ([87.118.116.4]:51543 "EHLO
	v6.tansi.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab3KWXCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Nov 2013 18:02:17 -0500
Content-Disposition: inline
In-Reply-To: <20131123221814.GG15822@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 23, 2013 at 23:18:14 CET, Hannes Frederic Sowa wrote:
> On Sat, Nov 23, 2013 at 11:11:51PM +0100, Arno Wagner wrote:
> > On Sat, Nov 23, 2013 at 21:39:33 CET, Hannes Frederic Sowa wrote:
> > > On Sat, Nov 23, 2013 at 09:20:47PM +0100, Arno Wagner wrote:
> > > > On Sat, Nov 23, 2013 at 17:45:58 CET, Ben Hutchings wrote:
> > > > > On Sat, 2013-11-23 at 13:11 +0100, Arno Wagner wrote:
> > > > > > On Sat, Nov 23, 2013 at 05:33:59 CET, Hannes Frederic Sowa wrote:
> > > > > [...]
> > > > > > > Could you try dropwatch while the packet drops are happening?
> > > > > > > Often it is helpful to check ip monitor all if events happen during bursty
> > > > > > > losses.
> > > > > > 
> > > > > > Sorry, but dropwatch is not in Debian and compiling it from sources
> > > > > > seem to require something called "rpmbuild". Hence I cannot use
> > > > > > it or at least would have to write my own Makefile for it. 
> > > > > 
> > > > > You could use 'perf script net_dropmonitor' instead.
> > > > 
> > > > That gets me "invalid or unsupported event: 'skb:kfree_skb'"
> > > > with 3.10.17, so I guess it will not work with 3.10.19 either.
> > > 
> > > You need CONFIG_DROP_MONITOR enabled on your kernel build.
> > 
> > Found it. At least if it actually is "CONFIG_NET_DROP_MONITOR".
> > 
> > Is there any less obscure way than greping the kernel tree and
> > tracing the options back to find out what meny entry turns on
> > what option?
> 
> I normally search in menuconfig (press '/').

Thanks, did not know about that one. Looks quite useful.

Anyways, I will run a test with that option and the tool.
in the next few days.

Arno

-- 
Arno Wagner,     Dr. sc. techn., Dipl. Inform.,    Email: arno@wagner.name
GnuPG: ID: CB5D9718  FP: 12D6 C03B 1B30 33BB 13CF  B774 E35C 5FA1 CB5D 9718
----
There are two ways of constructing a software design: One way is to make it
so simple that there are obviously no deficiencies, and the other way is to
make it so complicated that there are no obvious deficiencies. The first
method is far more difficult.  --Tony Hoare
