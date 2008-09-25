From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH 3/3] e1000e: remove failed request for sw/fw/hw flag
Date: Thu, 25 Sep 2008 03:00:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0809250257070.27884@twin.jikos.cz>
References: <20080923224630.6927.28967.stgit@jtkirshe-mobile.jf.intel.com>
 <48DAE089.20307@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@elte.hu>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:40175 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752547AbYIYBCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 21:02:37 -0400
In-Reply-To: <48DAE089.20307@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, Jeff Garzik wrote:

> > When the driver fails to acquire the control flag used to serialize
> > NVM and PHY accesses between the driver, firmware and hardware, remove the
> > request for the flag otherwise the hardware might grant the flag when it
> > becomes available but the driver will not release the flag.  This could
> > cause the firmware to prevent the driver getting the flag for all future
> > attempts.
> applied

BTW are you going to take the whole series, or just this fix?

I don't think that the other patches should be really applied to upstream 
(they could be very handy for debugging this horrible issue, once we could 
do any debugging of it, thoug), as they don't protect against anyone 
creating a new rw mapping, which can then be freely used to still 
overwrite the mmio area without any problems.

-- 
Jiri Kosina
SUSE Labs

