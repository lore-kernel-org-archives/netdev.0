From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 19:17:50 -0800 (PST)
Message-ID: <20140117.191750.492640836986884784.davem@davemloft.net>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaARDRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 22:17:51 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Fri, 17 Jan 2014 15:36:30 -0800

> This series contains updates to i40e.  
> 
> Neerav implements DCB and DCBNL support and adds DCB options
> to Kconfig.  DCB is disabled by default.
> 
> Anjali refactors flow control director to fix inconsistencies
> that were preventing clean unloads of the driver, move the
> queues for handling flow director error into their own hardware
> VSI and implement a corrected version of the basic ethtool add 
> ntuple rule.
> 
> Jesse provides fixes for a compiler warning, firmware workaround,
> white space fixes and renames some defines.
> 
> Shannon reworks the device ID #defines to follow the
> DEV_ID_ convention followed by our other drivers.

Series applied.
