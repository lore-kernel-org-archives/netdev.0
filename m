From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [patch] e1000=y && e1000e=m regression fix (was: Re: [regression] e1000e broke e1000)
Date: Thu, 10 Apr 2008 01:59:59 +0200
Message-ID: <m363uqwpds.fsf@maximus.localdomain>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com>
	<20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
	<20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org>
	<20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org>
	<20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org>
	<47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<200804092249.23111.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, jeff@garzik.org, matthew@wil.cx,
	auke-jan.h.kok@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-pci@atrey.karlin.mff.cuni.cz, akpm@linux-foundation.org,
	davem@davemloft.net, torvalds@linux-foundation.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	bruce.w.allan@intel.com, greg@kroah.com, arjan@linux.intel.com,
	rjw@sisk.pl
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35125 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbYDJAAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 20:00:05 -0400
In-Reply-To: <200804092249.23111.elendil@planet.nl> (Frans Pop's message of "Wed\, 9 Apr 2008 22\:49\:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frans Pop <elendil@planet.nl> writes:

> Fairly experienced user wants a kernel which supports his hardware without 
> having to load modules, but wants other modules available "just in case".
> So he takes his distro kernel and selectively changes some modules to 
> built-ins, including e1000.
> Next he upgrades to 2.6.25 and finds his NIC no longer works.

Nope, udev with normal distro config will load e1000e just fine.
A custom system, without automatic loading of modules (or with
unavailable module) could have this problem. A root fs on NFS or
something like that, too.

But while it can be changed for 2.6.25 it will break with 2.6.26 again,
definitely.
-- 
Krzysztof Halasa
