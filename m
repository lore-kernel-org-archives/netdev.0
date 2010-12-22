From: "juice" <juice@swagman.org>
Subject: Re: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 09:30:39 +0200
Message-ID: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Stephen Hemminger" <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:56585 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401Ab0LVHaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 02:30:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, 21 Dec 2010 11:56:42 +0200 shemminger wrote:
> I regularly get full 1G line rate of 64 byte packets using old Opteron
box and pktgen.  It does require some tuning of IRQ's and interrupt
mitigation but
> no patches. Did you remember to do the basic stuff like setting IRQ
affinity
> and not enabling debugging or tracing in the kernel? This is on sky2,
but
> also using e1000 and tg3. Others have reported 7M packets per second
over
> 10G cards.
> The r8169 hardware is low end consumer hardware and doesn't work as
well.
> It is possible to get close to 1G line rate forwarding with a single
core
> with current
> generation processors. Actual rate depends on hardware and configuration
(size of route
> table, firewalling, etc).  Much better performance with multi-queue
hardware to spread load
> over multiple cores.

I did my testing on two kinds of boxes we use in our lab, an older Pomi
Supermicro with e1000 and a newer Dell T3500 with tg3 and r8169.
Both computers have dual-core 2.4G Xeon Cpus, but with somewhat different
model and stepping.
Both boxes are running the same OS, Ubuntu 2.6.32-26-generic #48.

Could you share some information on the required interrupt tuning? It
would certainly be easiest if the full line rate can be achieved without
any patching of drivers or hindering normal eth/ip interface operation.

Yours, Jussi Ohenoja




