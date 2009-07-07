From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Tue, 7 Jul 2009 15:18:03 +0200
Message-ID: <20090707131803.GA6520@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <20090706163106.GA4559@ami.dom.local> <a5d9929e0907061023g4306d80ewfc8907653b949005@mail.gmail.com> <200907061926.43625.andres@anarazel.de> <20090707065014.GA3296@ami.dom.local> <a5d9929e0907070340y63280508t92e6c7e4ce464994@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andres Freund <andres@anarazel.de>
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47293 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbZGGNSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 09:18:15 -0400
Content-Disposition: inline
In-Reply-To: <a5d9929e0907070340y63280508t92e6c7e4ce464994@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2009 at 11:40:16AM +0100, Joao Correia wrote:
> I am now running 2.6.31-rc2 for a couple of hours, no freeze.
> 
> Let me know what/if i can help with tracking down the original source
> of the problem.

OK, so we know it's only about timers. Here is another tiny patch
(the previous one should be removed), which could tell (with oops) if
there's something while migrating. Anyway, the bug should be back :-(

Thanks,
Jarek P.
