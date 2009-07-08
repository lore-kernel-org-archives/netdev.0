From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 00:48:28 +0200
Message-ID: <20090708224828.GD3666@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907090023.18040.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:48298 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970AbZGHWyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:54:17 -0400
Content-Disposition: inline
In-Reply-To: <200907090023.18040.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2009 at 12:23:17AM +0200, Andres Freund wrote:
...
> Unfortunately this just yields the same backtraces during softlockup and not 
> earlier.
> I did not test without lockdep yet, but that should not have stopped the BUG 
> from appearing, right?

Since it looks like hrtimers now, these changes in timers shouldn't
matter. Let's wait for new ideas.

Thanks for testing anyway,
Jarek P.
