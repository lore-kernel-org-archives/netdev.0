From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: fix IFF_ALLMULTI handling
Date: Mon, 30 Sep 2013 19:49:50 -0400 (EDT)
Message-ID: <20130930.194950.1406135155659503628.davem@davemloft.net>
References: <1380576500-8531-1-git-send-email-peter@korsgaard.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joseph_chang@davicom.com.tw
To: peter@korsgaard.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451Ab3I3Xt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 19:49:56 -0400
In-Reply-To: <1380576500-8531-1-git-send-email-peter@korsgaard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 30 Sep 2013 23:28:20 +0200

> Pass-all-multicast is controlled by bit 3 in RX control, not bit 2
> (pass undersized frames).
> 
> Reported-by: Joseph Chang <joseph_chang@davicom.com.tw>
> Signed-off-by: Peter Korsgaard <peter@korsgaard.com>

Applied, thanks.

It would be so much better if these register values were all
properly documented, one by one, with macros.
