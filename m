From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: set EQ DB clear-intr bit in be_open()
Date: Fri, 11 Jul 2014 14:35:16 -0700 (PDT)
Message-ID: <20140711.143516.555804732326684256.davem@davemloft.net>
References: <1405067581-31955-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbaGKVfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 17:35:17 -0400
In-Reply-To: <1405067581-31955-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 11 Jul 2014 14:03:01 +0530

> From: Suresh Reddy <Suresh.Reddy@emulex.com>
> 
> On BE3, if the clear-interrupt bit of the EQ doorbell is not set the first
> time it is armed, ocassionally we have observed that the EQ doesn't raise
> anymore interrupts even if it is in armed state.
> This patch fixes this by setting the clear-interrupt bit when EQs are
> armed for the first time in be_open().
> 
> Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
> 
> David, could you pls queue this patch for the -stable tree. Thks.

Applied and queued up for -stable, thanks.
