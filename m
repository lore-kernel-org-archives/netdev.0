From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Mon, 14 Nov 2011 00:26:30 -0500 (EST)
Message-ID: <20111114.002630.2254622894958283155.davem@davemloft.net>
References: <1321024239-18861-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab1KNF0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:26:36 -0500
In-Reply-To: <1321024239-18861-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Fri, 11 Nov 2011 09:10:39 -0600

> The code for setting the address of the internal TBI PHY was
> convoluted enough without a maze of ifdefs. Clean it up a bit
> so we allow the logic to fail down to -ENODEV at the end of
> the if/else ladder, rather than using ifdefs to repeat the same
> failure code over and over.
> 
> Also, remove the support for the auto-configuration. I'm not aware of
> anyone using it, and it ends up using the bus mutex before it's been
> initialized.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied, thanks.
