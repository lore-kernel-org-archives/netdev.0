From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Reset dma descriptors on ndo_open
Date: Tue, 01 Oct 2013 02:01:34 -0400 (EDT)
Message-ID: <20131001.020134.756782177490714135.davem@davemloft.net>
References: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com>
	<20130930.212153.531876068589922786.davem@davemloft.net>
	<CAPybu_0OrwTo7CkuauRpu_ohQRY80U6BJDXQ6=KC0caOFiFCQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, jg1.han@samsung.com, gregkh@linuxfoundation.org,
	wfp5p@virginia.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3JAGBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 02:01:38 -0400
In-Reply-To: <CAPybu_0OrwTo7CkuauRpu_ohQRY80U6BJDXQ6=KC0caOFiFCQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Tue, 1 Oct 2013 07:46:31 +0200

> What if I move
>        lp->tx_bd_ci = 0;
>        lp->tx_bd_next = 0;
>        lp->tx_bd_tail = 0;
>        lp->rx_bd_ci = 0;
> 
> to temac_dma_bd_init? Will this be more correct?

Yes, that would be a lot better.
