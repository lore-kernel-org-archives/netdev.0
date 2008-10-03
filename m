From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 2.6.27-rc8 5/6] e1000e: debug contention on NVM SWFLAG
Date: Fri, 3 Oct 2008 17:39:17 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0810031736150.26779@jikos.suse.cz>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com> <20081002233340.12556.33137.stgit@jbrandeb-bw.jf.intel.com> <Pine.LNX.4.64.0810031346100.1532@twin.jikos.cz> <alpine.LFD.2.00.0810030812570.3230@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	arjan@linux.intel.com, airlied@gmail.com, davem@davemloft.net,
	Jeff Garzik <jeff@garzik.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42563 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751623AbYJCPjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2008 11:39:19 -0400
In-Reply-To: <alpine.LFD.2.00.0810030812570.3230@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Oct 2008, Linus Torvalds wrote:

> > The debugging message is racy anyway with respect to accessing 
> > nvm_owner, right? It should be done after the mutex has been 
> > succesfully acquired.
> It's done that way on purpose - to see who _could_ be racing.

I know. I just wanted to point out that we probably don't want the patch 
in 2.6.27 in this form, users wouldn't like to have warning in their logs 
every time mutex is not acquired on a first attempt :)

We are currently running reproduction tests on affected machines to verify 
that this patch really fixes the root cause of this whole e1000e saga.

-- 
Jiri Kosina
SUSE Labs
