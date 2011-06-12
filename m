From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netpoll: call dev_put() on error in netpoll_setup()
Date: Sat, 11 Jun 2011 18:55:40 -0700 (PDT)
Message-ID: <20110611.185540.1098507377577815147.davem@davemloft.net>
References: <20110611155047.GA3583@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, herbert@gondor.hengli.com.au,
	nhorman@tuxdriver.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab1FLB5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 21:57:03 -0400
In-Reply-To: <20110611155047.GA3583@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 11 Jun 2011 18:50:47 +0300

> There is a dev_put(ndev) missing on an error path.  This was
> introduced in 0c1ad04aecb "netpoll: prevent netpoll setup on slave
> devices".
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> This is a static checker bug, and it's possible I've misunderstood
> something.

Definitely looks correct to me, applied, thanks!
