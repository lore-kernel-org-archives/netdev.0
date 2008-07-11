From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND NET-NEXT PATCH 08/20] igb: Introduce multiple TX queues
 with	infrastructure
Date: Fri, 11 Jul 2008 01:22:12 -0400
Message-ID: <4876EE04.9090208@garzik.org>
References: <20080708220046.1518.88457.stgit@localhost.localdomain> <20080708220619.1518.52996.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49679 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbYGKFWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:22:17 -0400
In-Reply-To: <20080708220619.1518.52996.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> This code adds multiple Tx queue infrastructure much like we
> previously did in ixgbe. The MSI-X vector mapping is the bulk of
> the change.
> 
> IAM can now be safely enabled and we've verified that it does
> work correctly. We can also eliminate the tx ring lock.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/igb/igb.h      |    7 +-
>  drivers/net/igb/igb_main.c |  160 ++++++++++++++++++++++++++++++--------------
>  2 files changed, 114 insertions(+), 53 deletions(-)

applied 8-20


