From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 10/12] igb: move DMA Coalescing feature code into
 separate function.
Date: Wed, 12 Oct 2011 16:48:34 -0400 (EDT)
Message-ID: <20111012.164834.2208432778408483576.davem@davemloft.net>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318390708-12232-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.r.sowles@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1JLUsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 16:48:38 -0400
In-Reply-To: <1318390708-12232-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Oct 2011 20:38:26 -0700

> From: Jacob Sowles <jacob.r.sowles@intel.com>
> 
> DMA Coalescing code needs to be executed during reset, if enabled.  Moved
> code to separate function and added a call to it in igb_reset.
> 
> Signed-off-by: Jacob Sowles <jacob.r.sowles@intel.com>
> Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Something is wrong here, this patch just adds the new function but no
actual callers.
