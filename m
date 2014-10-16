From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: fix a use after free in vxlan_encap_bypass
Date: Wed, 15 Oct 2014 23:31:24 -0400 (EDT)
Message-ID: <20141015.233124.937905392153785825.davem@davemloft.net>
References: <1413420581-12989-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbaJPDb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 23:31:26 -0400
In-Reply-To: <1413420581-12989-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 16 Oct 2014 08:49:41 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> when netif_rx() is done, the netif_rx handled skb maybe be freed,
> and should not be used.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Looks good, applied, and queued up for -stable thanks!
