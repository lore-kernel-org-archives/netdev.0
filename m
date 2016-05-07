From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Reset dcb state machine and tx queue
 prio only if dcb is enabled
Date: Sat, 07 May 2016 15:16:05 -0400 (EDT)
Message-ID: <20160507.151605.680566397138476812.davem@davemloft.net>
References: <1462426539-5729-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbcEGTQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:16:08 -0400
In-Reply-To: <1462426539-5729-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  5 May 2016 11:05:39 +0530

> When cxgb4 is enabled with CONFIG_CHELSIO_T4_DCB set, VI enable command
> gets called with DCB enabled. But when we have a back to back setup with
> DCB enabled on one side and non-DCB on the Peer side. Firmware doesn't
> send any DCB_L2_CFG, and DCB priority is never set for Tx queue.
> But driver resets the queue priority and state machine whenever there
> is a link down, this patch fixes it by adding a check to reset only if
> cxgb4_dcb_enabled() returns true.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
