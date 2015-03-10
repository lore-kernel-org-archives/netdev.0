From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: enable interrupts after napi_complete()
Date: Mon, 09 Mar 2015 22:38:07 -0400 (EDT)
Message-ID: <20150309.223807.1531639361539445291.davem@davemloft.net>
References: <1425953739-30149-1-git-send-email-yongbae2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: msink@permonline.ru, nicolas.ferre@atmel.com, tklauser@distanz.ch,
	wsa@the-dreams.de, varkabhadram@gmail.com, netdev@vger.kernel.org
To: yongbae2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCJCiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:38:09 -0400
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

There is no need to post the patch multiple times, once is
enough.
