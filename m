From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: support TX batching using
 skb->xmit_more flag
Date: Mon, 05 Jan 2015 16:33:17 -0500 (EST)
Message-ID: <20150105.163317.733449445319916193.davem@davemloft.net>
References: <1420454914-9516-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbbAEVdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:33:19 -0500
In-Reply-To: <1420454914-9516-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 5 Jan 2015 05:48:34 -0500

> This patch uses skb->xmit_more flag to batch TX requests.
> TX is flushed either when xmit_more is false or there is
> no more space in the TXQ.
> 
> Skyhawk-R and BEx chips require an even number of wrbs to be posted.
> So, when a batch of TX requests is accumulated, the last header wrb
> may need to be fixed with an extra dummy wrb.
> 
> This patch refactors be_xmit() routine as a sequence of be_xmit_enqueue()
> and be_xmit_flush() calls. The Tx completion code is also
> updated to be able to unmap/free a batch of skbs rather than a single
> skb.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
