From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macb: Keep driver's speed/duplex in sync with
 actual NCFGR
Date: Sat, 03 Nov 2012 15:38:13 -0400 (EDT)
Message-ID: <20121103.153813.1907662993079093598.davem@davemloft.net>
References: <201211021909.25473.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	plagnioj@jcrosoft.com, havard@skinnemoen.net, jamie@jamieiles.com,
	linux-arm-kernel@lists.infradead.org
To: vitas@nppfactor.kiev.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab2KCTiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:38:15 -0400
In-Reply-To: <201211021909.25473.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Date: Fri, 2 Nov 2012 19:09:24 +0200

> When underlying phy driver restores its state very fast after being brought 
> down and up so that macb driver function macb_handle_link_change() was never 
> called with link state "down", driver's internal representation of phy speed 
> and duplex (bp->speed and bp->duplex) didn't change. So, macb driver sees no 
> reason to perform actual write to the NCFGR register, although the speed and 
> duplex settings in that register were reset when interface was brought down 
> and up. In that case actual phy speed and duplex differ from NCFGR settings.
> The patch fixes that by keeping internal driver representation of speed and 
> duplex in sync with actual content of NCFGR.
> 
> Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>

Applied.
