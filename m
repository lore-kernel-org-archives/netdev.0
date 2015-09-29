From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skbuff: Fix skb checksum partial check.
Date: Tue, 29 Sep 2015 16:49:32 -0700 (PDT)
Message-ID: <20150929.164932.1619659673911486443.davem@davemloft.net>
References: <1443486265-2246-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbI2Xtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:49:33 -0400
In-Reply-To: <1443486265-2246-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 28 Sep 2015 17:24:25 -0700

> Earlier patch 6ae459bda tried to detect void ckecksum partial
> skb by comparing pull length to checksum offset. But it does
> not work for all cases since checksum-offset depends on
> updates to skb->data.
> 
> Following patch fixes it by validating checksum start offset
> after skb-data pointer is updated. Negative value of checksum
> offset start means there is no need to checksum.
> 
> Fixes: 6ae459bda ("skbuff: Fix skb checksum flag on skb pull")
> Reported-by: Andrew Vagin <avagin@odin.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> This and 6ae459bda patches needs to be backported to stable.

Applied and both queued up for -stable, thanks.
