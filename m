From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: IRQ names require allocated memory
Date: Tue, 09 Dec 2014 13:13:57 -0500 (EST)
Message-ID: <20141209.131357.1625426039529204702.davem@davemloft.net>
References: <20141203000718.17370.31628.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbaLISN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:13:59 -0500
In-Reply-To: <20141203000718.17370.31628.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 2 Dec 2014 18:07:18 -0600

> When requesting an irq, the name passed in must be (part of) allocated
> memory. The irq name was a local variable and resulted in random
> characters when listing /proc/interrupts. Add a character field to the
> xgbe_channel structure to hold the irq name and use that.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
