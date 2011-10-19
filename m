From: David Miller <davem@davemloft.net>
Subject: Re: [patch] filter: use unsigned int to silence static checker
 warning
Date: Wed, 19 Oct 2011 19:36:05 -0400 (EDT)
Message-ID: <20111019.193605.621716042975197432.davem@davemloft.net>
References: <20111018070420.GR27732@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, xiaosuo@gmail.com,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab1JSXgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:36:10 -0400
In-Reply-To: <20111018070420.GR27732@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 18 Oct 2011 10:04:20 +0300

> This is just a cleanup.
> 
> My testing version of Smatch warns about this:
> net/core/filter.c +380 check_load_and_stores(6)
> 	warn: check 'flen' for negative values
> 
> flen comes from the user.  We try to clamp the values here between 1
> and BPF_MAXINSNS but the clamp doesn't work because it could be
> negative.  This is a bug, but it's not exploitable.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks Dan.
