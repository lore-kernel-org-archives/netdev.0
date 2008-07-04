From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 07/18] igb: add NAPI Rx queue support
Date: Fri, 04 Jul 2008 08:49:13 -0400
Message-ID: <486E1C49.7030503@garzik.org>
References: <20080627175921.22428.52767.stgit@localhost.localdomain> <20080627180035.22428.73511.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56348 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbYGDMtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:49:17 -0400
In-Reply-To: <20080627180035.22428.73511.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> Update the NAPI implementation to use the new napi_struct infrstructure.
> This removes the need of multiple net_device structs to implement a
> multiqueue NAPI.
> 
> Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr.@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/igb.h      |    2 +
>  drivers/net/igb/igb_main.c |  148 ++++++++++++++++++--------------------------
>  2 files changed, 61 insertions(+), 89 deletions(-)

applied 1-7 to net-next


