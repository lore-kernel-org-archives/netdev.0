From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/4] bonding: Reorg bond_alb_xmit code
Date: Thu, 24 Apr 2014 13:05:05 -0400 (EDT)
Message-ID: <20140424.130505.1571547886383054250.davem@davemloft.net>
References: <1398209418-3773-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, edumazet@google.com, maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758599AbaDXRFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:05:07 -0400
In-Reply-To: <1398209418-3773-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 22 Apr 2014 16:30:18 -0700

> Separating the actual xmit part from the function in a separate
> function that can be used in the tlb_xmit in the next patch. Also
> there is no reason do_tx_balance to be an int so changing it to
> bool type.
> 
> Change-Id: I9c48ff30487810f68587e621a191db616f49bd3b
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
