From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] e1000e: write protect ICHx NVM to prevent malicious
 write/erase
Date: Thu, 2 Oct 2008 11:59:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810021154330.1887@twin.jikos.cz>
References: <20081002001830.5951.3123.stgit@jbrandeb-bw.jf.intel.com>
 <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: torvalds@linux-foundation.org, jeff@garzik.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	Bruce Allan <bruce.w.allan@intel.com>, arjan@linux.intel.com
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:51291 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbYJBKA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 06:00:26 -0400
In-Reply-To: <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008, Jesse Brandeburg wrote:

> Set the hardware to ignore all write/erase cycles to the GbE region in 
> the ICHx NVM.  This feature can be disabled by the WriteProtectNVM 
> module parameter (enabled by default) only after a hardware reset, but 
> the machine must be power cycled before trying to enable writes.

Hi,

thanks. We have been running our tests with complete pileup of 12 patches 
from Intel, and the bug didn't trigger so far (and it triggers now pretty 
reliably with the unpatched kernel in the setup Karsten has established in 
our testing environment).

So the patches really seem, as far as our current testing goes, to 
at least workaround the problem.

I will now try to isolate which of the patches really fixes the problem, 
so that we could understand better what is going on and who is causing the 
corruption.

Do you think it would be possible to adapt this particular patch so that 
it spits out watnin/stacktrace when write and/or erase cycle is attempted 
but denied?

Thanks,

-- 
Jiri Kosina
SUSE Labs

