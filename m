From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 08/18] igb: Introduce multiple TX queues with
 infrastructure
Date: Fri, 04 Jul 2008 08:43:10 -0400
Message-ID: <486E1ADE.50706@garzik.org>
References: <20080627175921.22428.52767.stgit@localhost.localdomain> <20080627180044.22428.21729.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54578 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945AbYGDMnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:43:14 -0400
In-Reply-To: <20080627180044.22428.21729.stgit@localhost.localdomain>
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
>  drivers/net/igb/igb.h      |    6 +-
>  drivers/net/igb/igb_main.c |  160 ++++++++++++++++++++++++++++++--------------
>  2 files changed, 113 insertions(+), 53 deletions(-)

presumably this should wait for david to finish his multi-TX stuff?


