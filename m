From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/15] sfc: ndo_get_phys_port_id, vadaptor
 stats and PF unload when Vf's assigned to guest
Date: Tue, 02 Jun 2015 13:02:08 -0700 (PDT)
Message-ID: <20150602.130208.1434813585466450939.davem@davemloft.net>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbbFBTvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 15:51:01 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Tue, 2 Jun 2015 11:36:00 +0100

> This is the third and last instalment of SRIOV for EF10 patches.
> 
> This patch set includes implementation of ndo_get_phys_port_id
> and changes to the MAC statistics code in order to support
> vadaptor statistics.
> 
> It also includes code to deal with PF unload when Vf's are still
> assigned to the guest.
> 
> The first couple of patches create sysfs files for physical port
> and link control flags which are particularly useful when we have
> enabled a large number of VF's.
> 
> These patches have been tested with and without CONFIG_SFC_SRIOV.
> The creation and content of the sysfs files has been tested.
> The statistics are tested using ethtool for monitoring.

Series applied, thanks.
