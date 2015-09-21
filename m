From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] 8139cp: Use dev_kfree_skb_any() instead of
 dev_kfree_skb() in cp_clean_rings()
Date: Sun, 20 Sep 2015 22:24:01 -0700 (PDT)
Message-ID: <20150920.222401.1051937779601337236.davem@davemloft.net>
References: <1442531948.97487.8.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbbIUFYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:24:06 -0400
In-Reply-To: <1442531948.97487.8.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 18 Sep 2015 00:19:08 +0100

> This can be called from cp_tx_timeout() with interrupts disabled.
> Spotted by Francois Romieu <romieu@fr.zoreil.com>
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
