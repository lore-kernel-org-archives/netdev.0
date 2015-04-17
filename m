From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] altera tse: Fix network-delays and
 -retransmissions after high throughput.
Date: Fri, 17 Apr 2015 15:13:45 -0400 (EDT)
Message-ID: <20150417.151345.2068983759578980838.davem@davemloft.net>
References: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
	<1429220888-18119-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com,
	andreas@oetken.name
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbDQTNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 15:13:48 -0400
In-Reply-To: <1429220888-18119-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Thu, 16 Apr 2015 23:48:08 +0200

> From: Andreas Oetken <andreas@oetken.name>
> 
> Fix bug which occurs when more than <limit> packets are available during
> napi-poll, leading to "delays" and retransmissions on the network.
> 
> Check for (count < limit) before checking the get_rx_status in tse_rx-function.
> Function get_rx_status is reading from the response-fifo.
> If there is currently a response in the fifo,
> reading the last byte of the response pops the value from the fifo.
> If the limit is checked as second condition
> and the limit is reached the fifo is popped but the packet is not processed.
> 
> Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>

Applied, thanks.
