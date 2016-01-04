From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] bnxt_en: Support combined and rx/tx
 channels.
Date: Mon, 04 Jan 2016 15:55:31 -0500 (EST)
Message-ID: <20160104.155531.474952993170321598.davem@davemloft.net>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbcADUzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:55:35 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Sat, 2 Jan 2016 23:44:57 -0500

> The bnxt hardware uses a completion ring for rx and tx events.  The driver
> has to process the completion ring entries sequentially for the events.
> The current code only supports an rx/tx ring pair for each completion ring.
> This patch series add support for using a dedicated completion ring for
> rx only or tx only as an option configuarble using ethtool -L.
> 
> The benefits for using dedicated completion rings are:
> 
> 1. A burst of rx packets can cause delay in processing tx events if the
> completion ring is shared.  If tx queue is stopped by BQL, this can cause
> delay in re-starting the tx queue.
> 
> 2. A completion ring is sized according to the rx and tx ring size rounded
> up to the nearest power of 2.  When the completion ring is shared, it is
> sized by adding the rx and tx ring sizes and then rounded to the next power
> of 2, often with a lot of wasted space.
> 
> 3. Using dedicated completion ring, we can adjust the tx and rx coalescing
> parameters independently for rx and tx.

Series applied, thanks Michael.
