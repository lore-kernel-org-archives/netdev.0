From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ucc_geth: fix for RX skb buffers recycling
Date: Wed, 16 Jun 2010 18:17:12 -0700 (PDT)
Message-ID: <20100616.181712.191401750.davem@davemloft.net>
References: <1275935894-30483-2-git-send-email-geomatsi@gmail.com>
	<20100609.180240.59675642.davem@davemloft.net>
	<20100614203520.23a02c25@realm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	avorontsov@ru.mvista.com
To: geomatsi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53511
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752089Ab0FQBRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 21:17:00 -0400
In-Reply-To: <20100614203520.23a02c25@realm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Matyukevich <geomatsi@gmail.com>
Date: Mon, 14 Jun 2010 20:35:20 +0400

> This patch implements a proper modification of RX skb buffers before
> recycling. Adjusting only skb->data is not enough because after that
> skb->tail and skb->len become incorrect.
> 
> Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>

Applied, thanks.
