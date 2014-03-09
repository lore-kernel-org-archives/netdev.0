From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2: Fix shutdown sequence
Date: Sun, 09 Mar 2014 19:02:47 -0400 (EDT)
Message-ID: <20140309.190247.1719926927651537275.davem@davemloft.net>
References: <1394408732-1269-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbaCIXCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 19:02:48 -0400
In-Reply-To: <1394408732-1269-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Sun, 9 Mar 2014 15:45:32 -0800

> The pci shutdown handler added in:
> 
>     bnx2: Add pci shutdown handler
>     commit 25bfb1dd4ba3b2d9a49ce9d9b0cd7be1840e15ed
> 
> created a shutdown down sequence without chip reset if the device was
> never brought up.  This can cause the firmware to shutdown the PHY
> prematurely and cause MMIO read cycles to be unresponsive.  On some
> systems, it may generate NMI in the bnx2's pci shutdown handler.
> 
> The fix is to tell the firmware not to shutdown the PHY if there was
> no prior chip reset.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
> Please consider adding this to -stable.

Applied and queued up for -stable, thanks Michael.
