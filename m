From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: fec: Fix sparse warnings with different
 lock contexts for basic block
Date: Tue, 14 Oct 2014 12:53:56 -0400 (EDT)
Message-ID: <20141014.125356.683543714454912616.davem@davemloft.net>
References: <1413168828-9335-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com, sparse@chrisli.org,
	B20596@freescale.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779AbaJNQx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:53:58 -0400
In-Reply-To: <1413168828-9335-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Mon, 13 Oct 2014 10:53:48 +0800

> reproduce:
> make  ARCH=arm C=1 2>fec.txt drivers/net/ethernet/freescale/fec_main.o
> cat fec.txt
> 
> sparse warnings:
> drivers/net/ethernet/freescale/fec_main.c:2916:12: warning: context imbalance
> in 'fec_set_features' - different lock contexts for basic block
> 
> Christopher Li suggest to change as below:
> 	if (need_lock) {
> 		lock();
> 		do_something_real();
> 		unlock();
> 	} else {
> 		do_something_real();
> 	}
> 
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Suggested-by: Christopher Li <sparse@chrisli.org>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
