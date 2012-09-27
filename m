From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Clean up remaining iounmap
Date: Thu, 27 Sep 2012 19:19:18 -0400 (EDT)
Message-ID: <20120927.191918.866136563370603675.davem@davemloft.net>
References: <1348680122-9711-1-git-send-email-nhorman@tuxdriver.com>
	<1348684433.7220.78.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, mcan@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I0XTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:19:20 -0400
In-Reply-To: <1348684433.7220.78.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 26 Sep 2012 11:33:53 -0700

> On Wed, 2012-09-26 at 13:22 -0400, Neil Horman wrote: 
>> commit c0357e975afdbbedab5c662d19bef865f02adc17 modified bnx2 to switch from
>> using ioremap/iounmap to pci_iomap/pci_iounmap.  They missed a spot in the error
>> path of bnx2_init_one though.  This patch just cleans that up.
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> CC: Michael Chan <mcan@broadcom.com>
>> CC: "David S. Miller" <davem@davemloft.net>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
