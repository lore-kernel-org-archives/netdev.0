From: David Miller <davem@davemloft.net>
Subject: Re: [patch] inetpeer: initialize ->redirect_genid in inet_getpeer()
Date: Tue, 17 Jan 2012 15:52:31 -0500 (EST)
Message-ID: <20120117.155231.1181293038505383400.davem@davemloft.net>
References: <20120117204843.GA20999@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469Ab2AQUzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:55:12 -0500
In-Reply-To: <20120117204843.GA20999@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Jan 2012 23:48:43 +0300

> kmemcheck complains that ->redirect_genid doesn't get initialized.
> Presumably it should be set to zero.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

It's a "don't care" until we actually get a redirect, but I've applied
your patch nonetheless.

Thanks.
