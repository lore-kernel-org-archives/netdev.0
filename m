From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: mediatek: remove superfluous free_irq() call
Date: Mon, 04 Jul 2016 23:56:45 -0700 (PDT)
Message-ID: <20160704.235645.267168312192459724.davem@davemloft.net>
References: <1467639430-64370-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932874AbcGEG4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 02:56:46 -0400
In-Reply-To: <1467639430-64370-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <john@phrozen.org>
Date: Mon,  4 Jul 2016 15:37:10 +0200

> Commit 8067302973a1 ("net-next: mediatek: add support for IRQ grouping")
> adds handling for irq 1 and 2 to the uninit function but did not remove
> irq 0 which is not used since irq grouping was introduced. Fix this by
> removing the superfluous call to free_irq().
> 
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: John Crispin <john@phrozen.org>

Applied.
