From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] be2net: use stats-sync to read/write
 64-bit stats
Date: Mon, 01 Aug 2011 01:55:13 -0700 (PDT)
Message-ID: <20110801.015513.252408022668849313.davem@davemloft.net>
References: <1311657015-23465-1-git-send-email-sathya.perla@emulex.com>
	<1311657015-23465-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab1HAIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:55:15 -0400
In-Reply-To: <1311657015-23465-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 26 Jul 2011 10:40:15 +0530

> 64-bit stats in be2net are written/read as follows using the stats-sync
> interface for safe access in 32-bit archs:
> 
> 64-bit 		sync			writer			reader
> stats
> ------------------------------------------------------------------------------
> tx_stats	tx_stats->sync		be_xmit			be_get_stats64,
> 								ethtool
> tx-compl	tx_stats->sync_compl	tx-compl-processing	ethtool
> rx-stats	rx_stats->sync		rx-compl-processing	be_get_stats64,
> 								ethtool,
> 								eqd-update
> 
> This patch is based on Stephen Hemminger's earlier patch on the same issue...
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Queued up for net-next
