From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: Fix for Qset error due to CQ full
Date: Thu, 25 Feb 2016 16:25:48 -0500 (EST)
Message-ID: <20160225.162548.782902392289793973.davem@davemloft.net>
References: <1456312250-25694-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com,
	robert.richter@caviumnetworks.com, jerin.jacob@caviumnetworks.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbcBYVZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:25:51 -0500
In-Reply-To: <1456312250-25694-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sunil.kovvuri@gmail.com
Date: Wed, 24 Feb 2016 16:40:50 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> On Thunderx pass 1.x and pass2 due to a HW errata default CQ
> DROP_LEVEL of 0x80 is not sufficient to avoid CQ_WR_FULL Qset
> error when packets are being received at >20Mpps resulting in
> complete stall of packet reception.
> 
> This patch will configure it to 0x100 which is what is expected
> by HW on Thunderx. On future passes of thunderx and other chips
> HW default/reset value will be 0x100 or higher hence not overwritten.
> 
> Signed-off-by: Jerin Jacob <jerin.jacob@caviumnetworks.com>
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>

Applied, thank you.
