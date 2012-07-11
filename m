From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2: Fix bug in bnx2_free_tx_skbs().
Date: Tue, 10 Jul 2012 23:37:34 -0700 (PDT)
Message-ID: <20120710.233734.1549210481505224976.davem@davemloft.net>
References: <1341950680-12266-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab2GKGhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:37:35 -0400
In-Reply-To: <1341950680-12266-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 10 Jul 2012 13:04:40 -0700

> In rare cases, bnx2x_free_tx_skbs() can unmap the wrong DMA address
> when it gets to the last entry of the tx ring.  We were not using
> the proper macro to skip the last entry when advancing the tx index.
> 
> Reported-by: Zongyun Lai <zlai@vmware.com>
> Reviewed-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable.
