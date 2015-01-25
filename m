From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Let OS arch support adjust DMA mask
 as needed
Date: Sun, 25 Jan 2015 14:54:16 -0800 (PST)
Message-ID: <20150125.145416.2119862314149568126.davem@davemloft.net>
References: <20150120204755.23431.37523.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbAYWyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 17:54:17 -0500
In-Reply-To: <20150120204755.23431.37523.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 20 Jan 2015 14:47:55 -0600

> Set the DMA mask to 64-bit and let the underlying arch support adjust
> it as appropriate based on device tree DMA ranges, etc.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

That's not how this works.

The interface will fail if you ask for more bits than can be
supported, so you should pass in the amount of bits you actually need
but not more.

I'm not applying this.
