From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] net/mlx4: fix small memory leak on error
Date: Wed, 03 Jul 2013 16:52:47 -0700 (PDT)
Message-ID: <20130703.165247.254595318979763597.davem@davemloft.net>
References: <20130703093746.GE1598@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@purestorage.com,
	jackm@dev.mellanox.co.il, ronye@mellanox.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841Ab3GCXws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:52:48 -0400
In-Reply-To: <20130703093746.GE1598@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 3 Jul 2013 12:37:46 +0300

> "work" needs to be freed before returning on this error path.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
