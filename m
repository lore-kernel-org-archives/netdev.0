From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Thu, 05 Jan 2012 13:26:37 -0500 (EST)
Message-ID: <20120105.132637.2130515220408371607.davem@davemloft.net>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com,
	avorontsov@mvista.com
To: manfred.rudigier@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab2AES0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:26:52 -0500
In-Reply-To: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Rudigier <manfred.rudigier@omicron.at>
Date: Thu, 5 Jan 2012 15:50:21 +0100

> +
> +		/* Keep sock if we must return a time stamp on the err queue */
> +		skb_new->sk = skb->sk;

When I see something like this without any kind of reference counting or
similar, I am gravely concerned.
