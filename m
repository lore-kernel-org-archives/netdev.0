From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: make ndev->irq signed for error handling
Date: Thu, 07 Nov 2013 19:13:57 -0500 (EST)
Message-ID: <20131107.191357.715504104393441553.davem@davemloft.net>
References: <20131107074849.GF21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3KHAN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:13:59 -0500
In-Reply-To: <20131107074849.GF21844@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 7 Nov 2013 10:48:49 +0300

> There is a bug in cpsw_probe() where we do:
> 
> 	ndev->irq = platform_get_irq(pdev, 0);
> 	if (ndev->irq < 0) {
> 
> The problem is that "ndev->irq" is unsigned so the error handling
> doesn't work.  I have changed it to a regular int.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Even though some simplifications have been suggested wrt. how
this irq value is obtained in the one place where it is used,
I am applying Dan's patch for now.
