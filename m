From: denys@visp.net.lb
Subject: Re: NMI lockup, 2.6.26 release
Date: Thu, 24 Jul 2008 17:56:43 +0300
Message-ID: <200807241756.43595.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <20080723232456.GA5835@ami.dom.local> <200807240256.36098.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:38465 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbYGXO45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:56:57 -0400
In-Reply-To: <200807240256.36098.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing yet. Still waiting, in 6 hours i will have "peak time".
But yesterday with same settings(without patch) it crashed 3 times.

It is Core2Duo E6750 CPU, clocksource is TSC.
TSC synchronization is always passed. HPET is available, so in case... i can try it too.
It was crashing with nmi_watchdog=1(at least it brings crash message) and without it (hard lockup).
Fishy point is ifb, but i have few hundreds of NAS servers with ifb + htb 
(but sure not 300-400 Mbps like on this host) and i check weekly log on all of them - none of them crashed.

So it is or hardware specific (but it is crashing always in same point), 
even maybe memory corruption, it is not a server-grade equipment, but it crashes always in same place, same way.
I have running MCE, so if there is thermal events - it must catch it.
But sure there is large list of errata for this hardware :-)


On Thursday 24 July 2008, denys@visp.net.lb wrote:
> I dont have any problem to restart :-)
> Build system and restart (over kexec) is automated..
> Rebooting now.


