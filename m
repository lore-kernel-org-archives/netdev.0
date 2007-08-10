From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 14:11:24 -0700
Message-ID: <46BCD47C.9060408@candelatech.com>
References: <20070810202426.GA25050@havoc.gtf.org> <46BCD263.6050807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50890 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756259AbXHJVLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:11:41 -0400
In-Reply-To: <46BCD263.6050807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> This patch copies Auke in adding NETIF_F_LRO.  Is that just for 
> temporary merging, or does the net core really not touch it at all?
> 
> Because, logically, if NETIF_F_LRO exists nowhere else but this patch, 
> we should not add it to dev->features.  LRO knowledge can be contained 
> entirely within the driver, if the net core never tests NETIF_F_LRO.
> 
> I haven't reviewed the other NETIF_F_XXX flags, but, that logic can be 
> applied to any other NETIF_F_XXX flag:  if the net stack isn't using it, 
> it's a piece of information specific to that driver.

I believe LRO is going to have to be disabled for routing/bridging,
so the stack will probably need to become aware of it at some point...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

