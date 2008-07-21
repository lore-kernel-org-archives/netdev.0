From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gianfar: do not touch net queue in adjust_link
 phylib callback
Date: Mon, 21 Jul 2008 08:30:10 -0700 (PDT)
Message-ID: <20080721.083010.133624499.davem@davemloft.net>
References: <20080721151721.GA7989@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751554AbYGUPaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:30:10 -0400
In-Reply-To: <20080721151721.GA7989@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Mon, 21 Jul 2008 19:17:21 +0400

> If the net queue has not been started, we'll get this nice oops
> and non-working ethernet:
 ...
> Since the driver is using phylib (which is doing netif_carrier_on/off()),
> we should simply remove netif_tx_schedule_all() from adjust_link().
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
