From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] at86rf230: remove unnecessary / dead code
Date: Mon, 08 Apr 2013 12:01:02 -0400 (EDT)
Message-ID: <20130408.120102.1787119888665978532.davem@davemloft.net>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
	<cover.1365107512.git.sascha@ps.nvbi.de>
	<c9c5bee7116dd5847ed9e2ebb8be49fcde0cc052.1365107512.git.sascha@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: sascha@ps.nvbi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936512Ab3DHQBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:01:03 -0400
In-Reply-To: <c9c5bee7116dd5847ed9e2ebb8be49fcde0cc052.1365107512.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Herrmann <sascha@ps.nvbi.de>
Date: Thu,  4 Apr 2013 23:02:00 +0200

> In at86rf230_probe() lp was first set to dev->priv and a few lines later
> dev->priv was set to lp again, without changing lp in between. The call
> to ieee802154_unregister_device() before err_irq: was unreachable.
> 
> Signed-off-by: Sascha Herrmann <sascha@ps.nvbi.de>

Applied.
