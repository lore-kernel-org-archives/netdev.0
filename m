From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Thu, 03 Nov 2011 22:44:28 -0400 (EDT)
Message-ID: <20111103.224428.2087649126851525828.davem@davemloft.net>
References: <1320357251-15335-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab1KDCod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 22:44:33 -0400
In-Reply-To: <1320357251-15335-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Thu, 3 Nov 2011 16:54:11 -0500

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

Cleanups of this nature are not appropriate to submit at this time,
please wait until the net-next tree becomes active again.
