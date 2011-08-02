From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Prevent restarting Tx during
 bnx2x_nic_unload
Date: Tue, 02 Aug 2011 01:35:52 -0700 (PDT)
Message-ID: <20110802.013552.1499728966977829509.davem@davemloft.net>
References: <201108021052.37368.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab1HBIf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 04:35:57 -0400
In-Reply-To: <201108021052.37368.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Tue, 2 Aug 2011 10:52:37 +0300

> Tx queues were stopped before  bp->state was changed to a value different 
> from BNX2X_STATE_OPEN, which allowed the bnx2x_tx_int() called from the 
> NAPI context to re-enable it. This then allowed the netdev->ndo_start_xmit() 
> to be called in the middle of the function reset and rings freeing. 
> 
> This patch changes bp->state to a value different 
> from BNX2X_STATE_OPEN BEFORE disabling the Tx queues in order to restore the
> broken protection against the above race in the bnx2x_tx_int().
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thansk Vlad.
