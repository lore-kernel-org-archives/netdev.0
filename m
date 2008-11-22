From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 14/14] e1000e: check return code from NVM
 accesses and fix bank detection
Date: Fri, 21 Nov 2008 17:02:53 -0800 (PST)
Message-ID: <20081121.170253.133376207.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190256.32313.2561.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753135AbYKVBCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:02:53 -0500
In-Reply-To: <20081121190256.32313.2561.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:02:56 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Check return code for all NVM accesses[1] and error out accordingly; log
> a debug message for failed accesses.
> 
> For ICH8/9, the valid NVM bank detect function was not checking whether the
> SEC1VAL (sector 1 valid) bit in the EECD register was itself valid (bits 8
> and 9 also have to be set).  If invalid, it would have defaulted to the
> possibly invalid bank 0.  Instead, try to use the valid bank detection
> method used by ICH10 which has been cleaned up a bit.
> 
> [1] - reads and updates only; not writes because those are only writing to
> the Shadow RAM, the update following the write is the only thing actually
> writing the modified Shadow RAM contents to the NVM.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>

Applied.

Thanks.
