From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] cs89x0: Move the driver into the Cirrus dir
Date: Fri, 07 Oct 2011 12:42:23 -0400 (EDT)
Message-ID: <20111007.124223.813814960082542819.davem@davemloft.net>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1317971926-23145-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<20111007.123936.390761582614065567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	nelson@crynwr.com, akpm@linux-foundation.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab1JGQm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:42:27 -0400
In-Reply-To: <20111007.123936.390761582614065567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 07 Oct 2011 12:39:36 -0400 (EDT)

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri,  7 Oct 2011 00:18:33 -0700
> 
>> The cs89x0 driver was initial placed in the apple/ when it
>> should have been placed in the cirrus/.  This resolves the
>> issue by moving the dirver and fixing up the respective
>> Kconfig(s) and Makefile(s).
>> 
>> Thanks to Sascha for reporting the issue.
>> 
>> CC: Russell Nelson <nelson@crynwr.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied.

Actually, reverted, you have to fix this:

[davem@ilbolle net-next]$ make oldconfig
scripts/kconfig/conf --oldconfig Kconfig
drivers/net/ethernet/apple/Kconfig:21:error: recursive dependency detected!
drivers/net/ethernet/apple/Kconfig:21:	symbol MACE depends on NET_VENDOR_APPLE
drivers/net/ethernet/apple/Kconfig:5:	symbol NET_VENDOR_APPLE depends on MACE
