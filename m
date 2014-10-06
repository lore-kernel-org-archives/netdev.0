From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: pxa168_eth: avoid using signed char for
 bitops
Date: Sun, 05 Oct 2014 21:19:16 -0400 (EDT)
Message-ID: <20141005.211916.2141017785429102158.davem@davemloft.net>
References: <1412348899-20586-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:19:18 -0400
In-Reply-To: <1412348899-20586-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Fri,  3 Oct 2014 17:08:19 +0200

> Signedness bugs may occur when using signed char for bitops,
> depending on if the highest bit is ever used.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
