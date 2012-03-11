From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7]
 drivers/net/irda/{ali-ircc,via-ircc,w83977af-ir}.c: ensure arguments to
 request_irq and free_irq are compatible
Date: Sun, 11 Mar 2012 15:42:26 -0700 (PDT)
Message-ID: <20120311.154226.1278106806584648233.davem@davemloft.net>
References: <1331502542-18094-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab2CKWpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:45:41 -0400
In-Reply-To: <1331502542-18094-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 11 Mar 2012 22:49:02 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Convert calls to free_irq so that the second argument is the same as the
> last argument of the corresponding call to request_irq.  Without this
> property, free_irq does nothing.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
