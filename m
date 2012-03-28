From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mISDN: array underflow in open_bchannel()
Date: Tue, 27 Mar 2012 22:42:43 -0400 (EDT)
Message-ID: <20120327.224243.1717299402560241334.davem@davemloft.net>
References: <20120327072048.GC19008@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, adobriyan@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756645Ab2C1Cmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:42:52 -0400
In-Reply-To: <20120327072048.GC19008@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 27 Mar 2012 10:20:48 +0300

> There are two channels here.  User space starts counting channels at one
> but in the kernel we start at zero.  If the user passes in a zero
> channel that's invalid and could lead to memory corruption.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
