From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Thu, 24 Jul 2008 19:45:53 +0200
Message-ID: <20080724174552.GA2513@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <20080723232456.GA5835@ami.dom.local> <200807240256.36098.denys@visp.net.lb> <200807241756.43595.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:30143 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbYGXRqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 13:46:13 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2249166ika.5
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 10:46:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807241756.43595.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 05:56:43PM +0300, denys@visp.net.lb wrote:
> Nothing yet. Still waiting, in 6 hours i will have "peak time".
> But yesterday with same settings(without patch) it crashed 3 times.

OK, so let's better wait to be sure of something here.

Jarek P.

(Btw., could try in the meantime to do something to shorten your lines?
It's not the most popular format on kernel lists...) 

> It is Core2Duo E6750 CPU, clocksource is TSC.
> TSC synchronization is always passed. HPET is available, so in case... i can try it too.
> It was crashing with nmi_watchdog=1(at least it brings crash message) and without it (hard lockup).
> Fishy point is ifb, but i have few hundreds of NAS servers with ifb + htb 
> (but sure not 300-400 Mbps like on this host) and i check weekly log on all of them - none of them crashed.
> 
> So it is or hardware specific (but it is crashing always in same point), 
> even maybe memory corruption, it is not a server-grade equipment, but it crashes always in same place, same way.
> I have running MCE, so if there is thermal events - it must catch it.
> But sure there is large list of errata for this hardware :-)
> 
> 
> On Thursday 24 July 2008, denys@visp.net.lb wrote:
> > I dont have any problem to restart :-)
> > Build system and restart (over kexec) is automated..
> > Rebooting now.
> 
> 
