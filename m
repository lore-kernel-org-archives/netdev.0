From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH] ixgbe: change config srrctl to only program
 one	register per VMDq/RSS id
Date: Wed, 03 Sep 2008 10:10:12 -0400
Message-ID: <48BE9AC4.9010905@garzik.org>
References: <20080830072910.8019.28627.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49354 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244AbYICOKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:10:15 -0400
In-Reply-To: <20080830072910.8019.28627.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so only one srrctl register is programmed per VMDq id, and if VMDq is not enabled it is one register per RSS queue.  Currently this function is working correctly for the multiqueue RSS and single queue cases, but if any advances features such as VMDq or DCB would have been enabled this function would have caused issues as it was not correct.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++----------
>  1 files changed, 15 insertions(+), 10 deletions(-)

applied


