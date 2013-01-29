From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][net-next] gianfar: Optimize struct gfar_priv_tx_q
 for two cache lines
Date: Tue, 29 Jan 2013 15:22:27 -0500 (EST)
Message-ID: <20130129.152227.957529528185001040.davem@davemloft.net>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3A2UW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:22:28 -0500
In-Reply-To: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 29 Jan 2013 15:55:10 +0200

> Resize and regroup structure members to eliminate memory holes and
> to pack the structure into 2 cache lines (from 3).
> tx_ring_size was resized from 4 to 2 bytes and few members were re-grouped
> in order to eliminate byte holes and achieve compactness.
> Where possible, few members were grouped according to their usage and access
> order (i.e. start_xmit vs. clean_tx_ring members), less important members
> were pushed at the end.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
