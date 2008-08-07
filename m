From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [UPDATED PATCH 7/7] igb: remove 82576 quad adapter
Date: Thu, 07 Aug 2008 01:58:04 -0400
Message-ID: <489A8EEC.5010403@garzik.org>
References: <20080804215531.16188.73257.stgit@localhost.localdomain> <20080804220032.16188.65651.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41703 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbYHGF6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 01:58:07 -0400
In-Reply-To: <20080804220032.16188.65651.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> removing the 82576 quad adapter as it will not have completed testing by
> the time the kernel has been released.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/e1000_82575.c |    1 -
>  drivers/net/igb/e1000_hw.h    |    1 -
>  drivers/net/igb/igb_ethtool.c |    9 ---------
>  drivers/net/igb/igb_main.c    |   11 -----------
>  4 files changed, 0 insertions(+), 22 deletions(-)

applied patches 1-6 of 7

Did not apply this patch because we rarely yank code for this reason... 
typically testing is done in parallel with the open source community. 
Maybe more explanation is needed, if I'm misunderstanding?


