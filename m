From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bonding: style, comment and assertion
 changes
Date: Mon, 15 Sep 2014 17:20:49 -0400 (EDT)
Message-ID: <20140915.172049.2037428886134453050.davem@davemloft.net>
References: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbaIOVUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:20:51 -0400
In-Reply-To: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon, 15 Sep 2014 17:19:32 +0200

> This is a small and simple patch-set that doesn't introduce (hopefully) any
> functional changes, but only stylistic and semantic ones.
> Patch 01 simply uses the already provided __rlb_next_rx_slave function inside
> rlb_next_rx_slave(), thus removing the duplication of code.
> Patch 02 changes all comments that I could find to netdev style, removes
> some outdated ones and fixes a few more small cosmetic issues (new line
> after declaration, braces around if; else and such)
> Patch 03 removes one extra ASSERT_RTNL() because we already have it in the
> parent function and consolidates two other ASSERT_RTNL()s to the function
> that is exported and supposed to be called with RTNL anyway.

Series applied, thanks.
