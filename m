From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Tue, 12 Jan 2016 19:49:16 -0500
Message-ID: <20160113004916.GA28880@oracle.com>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35230 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbcAMAtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 19:49:45 -0500
Content-Disposition: inline
In-Reply-To: <20160106.163309.111867454969344145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/06/16 16:33), David Miller wrote:
> 
> A repeating pattern in drivers has become to use OF node information
> and, if not found, platform specific host information to extract the
> ethernet address for a given device.
    :
> Consolidate this into a portable routine, and provide the
> arch_get_platform_mac_address() weak function hook for all
> architectures to implement if they want.
    :
> As promised back in November, I'm commiting this into net-next
> now.  I'd work on the conversions of existing drivers, but I'd
> rather someone with access to the hardware to so.

I finally have all the ducks lined up for ixgbe/i40e around this. 
Should I go ahead and send this off (I think it first gets staged 
through Jeff's repo?) or is it better to wait for net-next to be 
open again?

--Sowmini
