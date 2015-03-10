From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: WIZnet drivers: enable interrupts after
 napi_complete()
Date: Tue, 10 Mar 2015 00:23:25 -0400 (EDT)
Message-ID: <20150310.002325.824529226906628278.davem@davemloft.net>
References: <1425954907-30417-1-git-send-email-yongbae2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msink@permonline.ru, nicolas.ferre@atmel.com, tklauser@distanz.ch,
	wsa@the-dreams.de, varkabhadram@gmail.com, netdev@vger.kernel.org
To: yongbae2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbCJEX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 00:23:27 -0400
In-Reply-To: <1425954907-30417-1-git-send-email-yongbae2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yongbae Park <yongbae2@gmail.com>
Date: Tue, 10 Mar 2015 11:35:07 +0900

> The interrupt is enabled before napi_complete(). A network timeout
> occurs if the interrupt handler is called before napi_complete().
> 
> Fix the bug by enabling the interrupt after napi_complete().
> 
> Signed-off-by: Yongbae Park <yongbae2@gmail.com>

Applied.
