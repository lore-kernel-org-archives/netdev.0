From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Fix race condition in driver when Rx frame
 is dropped
Date: Wed, 29 Apr 2015 15:25:02 -0400 (EDT)
Message-ID: <20150429.152502.1871572837950161327.davem@davemloft.net>
References: <c84f3773-71f2-431a-bc20-6a969d32eb63@BN1BFFO11FD033.protection.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, michals@xilinx.com,
	harinik@xilinx.com, kpc528@gmail.com,
	kalluripunnaiahchoudary@gmail.com, punnaia@xilinx.com
To: punnaiah.choudary.kalluri@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbbD2TZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:25:06 -0400
In-Reply-To: <c84f3773-71f2-431a-bc20-6a969d32eb63@BN1BFFO11FD033.protection.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Date: Wed, 29 Apr 2015 08:34:46 +0530

> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
> 
> Under heavy Rx load, observed that the Hw is updating the USED bit
> and it is not updating the received frame status to the BD control
> field. This could be lack of resources for processing the BDs at high
> data rates. Driver drops the frame associated with this BD but not
> clearing the USED bit. So, this is causing hang condition as Hw
> expects USED bit to be cleared for this BD.
> 
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

Applied, thanks.
