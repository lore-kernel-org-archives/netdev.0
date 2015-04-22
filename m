From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: Factor out one-time assignment from loop
Date: Wed, 22 Apr 2015 18:35:34 -0400 (EDT)
Message-ID: <20150422.183534.1565776428068622594.davem@davemloft.net>
References: <1429741734-29536-1-git-send-email-ben.shelton@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben.shelton@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934504AbbDVWfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:35:36 -0400
In-Reply-To: <1429741734-29536-1-git-send-email-ben.shelton@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Shelton <ben.shelton@ni.com>
Date: Wed, 22 Apr 2015 17:28:54 -0500

> In 02c958dd3 (net/macb: add TX multiqueue support for gem), the
> initialization of tx_head and tx_tail in macb_init_rings() was moved
> inside the loop that iterates over each element in the ring.  Since
> tx_head and tx_tail only need to be assigned once, move them back out of
> the loop.
> 
> Signed-off-by: Ben Shelton <ben.shelton@ni.com>

Yeah that makes sense, applied, thanks Ben.
