From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] e1000e: remove failed request for sw/fw/hw flag
Date: Wed, 24 Sep 2008 20:51:21 -0400
Message-ID: <48DAE089.20307@garzik.org>
References: <20080923224630.6927.28967.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47060 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbYIYAv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:51:29 -0400
In-Reply-To: <20080923224630.6927.28967.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When the driver fails to acquire the control flag used to serialize
> NVM and PHY accesses between the driver, firmware and hardware, remove the
> request for the flag otherwise the hardware might grant the flag when it
> becomes available but the driver will not release the flag.  This could
> cause the firmware to prevent the driver getting the flag for all future
> attempts.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/ich8lan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)

applied


