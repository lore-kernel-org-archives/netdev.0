From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: enable interrupts after napi_complete()
Date: Tue, 10 Mar 2015 00:23:14 -0400 (EDT)
Message-ID: <20150310.002314.1290013685738109871.davem@davemloft.net>
References: <1425953739-30149-1-git-send-email-yongbae2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msink@permonline.ru, nicolas.ferre@atmel.com, tklauser@distanz.ch,
	wsa@the-dreams.de, varkabhadram@gmail.com, netdev@vger.kernel.org
To: yongbae2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbCJEXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 00:23:20 -0400
In-Reply-To: <1425953739-30149-1-git-send-email-yongbae2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yongbae Park <yongbae2@gmail.com>
Date: Tue, 10 Mar 2015 11:15:39 +0900

> The interrupt is enabled before napi_complete(). A network timeout
> occurs if the interrupt handler is called before napi_complete().
> 
> Fix the bug by enabling the interrupt after napi_complete().
> 
> Signed-off-by: Yongbae Park <yongbae2@gmail.com>

Applied.
