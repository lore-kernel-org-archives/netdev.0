From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: Allocate fraglist early to avoid complex
 rollback
Date: Mon, 03 Aug 2015 22:23:15 -0700 (PDT)
Message-ID: <20150803.222315.50301920889896898.davem@davemloft.net>
References: <1438612683-5783-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com
To: ross.lagerwall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbHDFXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:23:16 -0400
In-Reply-To: <1438612683-5783-1-git-send-email-ross.lagerwall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ross Lagerwall <ross.lagerwall@citrix.com>
Date: Mon, 3 Aug 2015 15:38:03 +0100

> Determine if a fraglist is needed in the tx path, and allocate it if
> necessary before setting up the copy and map operations.
> Otherwise, undoing the copy and map operations is tricky.
> 
> This fixes a use-after-free: if allocating the fraglist failed, the copy
> and map operations that had been set up were still executed, writing
> over the data area of a freed skb.
> 
> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>

Applied, thanks.
