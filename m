From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] e1000e: remove failed request for sw/fw/hw flag
Date: Wed, 24 Sep 2008 21:29:49 -0400
Message-ID: <48DAE98D.3070208@garzik.org>
References: <20080923224630.6927.28967.stgit@jtkirshe-mobile.jf.intel.com> <48DAE089.20307@garzik.org> <Pine.LNX.4.64.0809250257070.27884@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@elte.hu>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52670 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYIYB35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 21:29:57 -0400
In-Reply-To: <Pine.LNX.4.64.0809250257070.27884@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Kosina wrote:
> On Wed, 24 Sep 2008, Jeff Garzik wrote:
> 
>>> When the driver fails to acquire the control flag used to serialize
>>> NVM and PHY accesses between the driver, firmware and hardware, remove the
>>> request for the flag otherwise the hardware might grant the flag when it
>>> becomes available but the driver will not release the flag.  This could
>>> cause the firmware to prevent the driver getting the flag for all future
>>> attempts.
>> applied
> 
> BTW are you going to take the whole series, or just this fix?

Just this fix

	Jeff



