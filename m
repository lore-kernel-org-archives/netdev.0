From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] e1000e: write protect ICHx NVM to prevent malicious
 write/erase
Date: Thu, 2 Oct 2008 15:02:11 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810021500470.1887@twin.jikos.cz>
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
Received: from twin.jikos.cz ([213.151.79.26]:34788 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276AbYJBNDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 09:03:17 -0400
In-Reply-To: <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008, Jesse Brandeburg wrote:

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Set the hardware to ignore all write/erase cycles to the GbE region in
> the ICHx NVM.  This feature can be disabled by the WriteProtectNVM module
> parameter (enabled by default) only after a hardware reset, but
> the machine must be power cycled before trying to enable writes.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: arjan@linux.intel.com

Does this impose any user-visible behavior change? (such as not being able 
to set up wake-on-lan, change MAC address, whatever).

-- 
Jiri Kosina
SUSE Labs

