From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/ethernet: ks8851_mll: signedness bug in
 ks8851_probe()
Date: Sun, 19 Feb 2012 18:58:42 -0500 (EST)
Message-ID: <20120219.185842.2291224018268083016.davem@davemloft.net>
References: <20120217064433.GC3666@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.weitzel@phytec.de, adobriyan@gmail.com,
	paul.gortmaker@windriver.com, thomas@m3y3r.de,
	danny.kukawka@bisect.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2BSX7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 18:59:16 -0500
In-Reply-To: <20120217064433.GC3666@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 17 Feb 2012 09:44:33 +0300

> netdev->irq is unsigned, so it's never less than zero.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
