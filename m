From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Fix pcie error recovery in case of
 NIC+RoCE adapters
Date: Fri, 19 Feb 2016 15:41:24 -0500 (EST)
Message-ID: <20160219.154124.1703304175474746678.davem@davemloft.net>
References: <1455745174-25211-1-git-send-email-padmanabh.ratnakar@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946460AbcBSUlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:41:25 -0500
In-Reply-To: <1455745174-25211-1-git-send-email-padmanabh.ratnakar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Date: Thu, 18 Feb 2016 03:09:34 +0530

> Interrupts registered by RoCE driver are not unregistered when
> msix interrupts are disabled during error recovery causing a
> crash. Detach the adapter instance from RoCE driver when error
> is detected to complete the cleanup. Attach the driver again after
> the adapter is recovered from error.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>

Applied.
