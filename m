From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/38] net/ibm/emac: fix type of phy_mode
Date: Tue, 22 Sep 2015 16:14:55 -0700 (PDT)
Message-ID: <20150922.161455.856766780037928790.davem@davemloft.net>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<1442842450-29769-19-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, ivan@ru.ibm.com, netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbbIVXO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:14:56 -0400
In-Reply-To: <1442842450-29769-19-git-send-email-a.hajda@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:50 +0200

> phy_mode can be negative.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2038576
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied.
