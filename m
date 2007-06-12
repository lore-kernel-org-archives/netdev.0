From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:17:44 -0700
Message-ID: <466F0D78.7090404@candelatech.com>
References: <466DEF9D.9070509@trash.net>	<1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net> <20070612.140240.00078635.davem@davemloft.net> <466F0C92.5080306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:52007 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbXFLVUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:20:01 -0400
In-Reply-To: <466F0C92.5080306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> If hardware w/ multiple queues will the capability for different MAC 
> addresses, different RX filters, etc. does it make sense to add that 
> below the net_device level?
> 
> We will have to add all the configuration machinery at the per-queue 
> level that already exists at the per-netdev level.

Perhaps the mac-vlan patch would be a good fit.  Currently it is all
software based, but if the hardware can filter on MAC, it can basically
do mac-vlan acceleration.  The mac-vlan devices are just like 'real' ethernet
devices, so they can be used with whatever schemes work with regular devices.

Thanks,
Ben

> 
>     Jeff
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

