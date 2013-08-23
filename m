From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: fix disabling TX in be_close()
Date: Thu, 22 Aug 2013 19:59:09 -0700 (PDT)
Message-ID: <20130822.195909.283809467190691309.davem@davemloft.net>
References: <1377154421-32013-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab3HWC7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 22:59:13 -0400
In-Reply-To: <1377154421-32013-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 22 Aug 2013 12:23:41 +0530

> commit fba875591 ("disable TX in be_close()") disabled TX in be_close()
> to protect be_xmit() from touching freed up queues in the AER recovery
> flow.  But, TX must be disabled *before* cleaning up TX completions in
> the close() path, not after. This allows be_tx_compl_clean() to free up
> all TX-req skbs that were notified to the HW.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied and queued up for -stable.
