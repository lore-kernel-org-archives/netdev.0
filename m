From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] benet: Wait f/w POST until timeout
Date: Tue, 05 Mar 2013 16:34:31 -0500 (EST)
Message-ID: <20130305.163431.2055740152739079020.davem@davemloft.net>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab3CEVee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 16:34:34 -0500
In-Reply-To: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Mon,  4 Mar 2013 15:48:46 +0800

> While PCI card faces EEH errors, reset (usually hot reset) is
> expected to recover from the EEH errors. After EEH core finishes
> the reset, the driver callback (be_eeh_reset) is called and wait
> the firmware to complete POST successfully. The original code would
> return with error once detecting failure during POST stage. That
> seems not enough.
> 
> The patch forces the driver (be_eeh_reset) to wait the firmware
> completes POST until timeout, instead of returning error upon
> detection POST failure immediately. Also, it would improve the
> reliability of the EEH funtionality of the driver.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

I know that patch #2 of this series needs to be implemented differently,
but this patch seems fine.

So can I get an ACK from one of the benet driver folks?

Thanks.
