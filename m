From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Pass ndm_state to route netlink FDB
 notifications.
Date: Wed, 16 Dec 2015 18:37:07 -0500 (EST)
Message-ID: <20151216.183707.441075703434515451.davem@davemloft.net>
References: <C039B2B452EFF24BA495644ED973419132ACE538@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hubert.sokolowski@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754907AbbLPXhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 18:37:08 -0500
In-Reply-To: <C039B2B452EFF24BA495644ED973419132ACE538@IRSMSX108.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sokolowski, Hubert" <hubert.sokolowski@intel.com>
Date: Tue, 15 Dec 2015 13:20:30 +0000

> Before this change applications monitoring FDB notifications
> were not able to determine whether a new FDB entry is permament
> or not:
> bridge fdb add f1:f2:f3:f4:f5:f8 dev sw0p1 temp self
> bridge fdb add f1:f2:f3:f4:f5:f9 dev sw0p1 self
> 
> bridge monitor fdb
> 
> f1:f2:f3:f4:f5:f8 dev sw0p1 self permanent
> f1:f2:f3:f4:f5:f9 dev sw0p1 self permanent
> 
> With this change ndm_state from the original netlink message
> is passed to the new netlink message sent as notification.
> 
> bridge fdb add f1:f2:f3:f4:f5:f6 dev sw0p1 self
> bridge fdb add f1:f2:f3:f4:f5:f7 dev sw0p1 temp self
> 
> bridge monitor fdb
> f1:f2:f3:f4:f5:f6 dev sw0p1 self permanent
> f1:f2:f3:f4:f5:f7 dev sw0p1 self static
> 
> Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>

This looks fine, applied, thanks.
