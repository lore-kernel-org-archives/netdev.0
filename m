From: David Miller <davem@davemloft.net>
Subject: Re: [patch] gre: information leak in ip6_tnl_ioctl()
Date: Mon, 20 Aug 2012 02:21:43 -0700 (PDT)
Message-ID: <20120820.022143.843914975656895005.davem@davemloft.net>
References: <20120816131404.GA23188@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab2HTJVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:21:46 -0400
In-Reply-To: <20120816131404.GA23188@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 16 Aug 2012 16:14:04 +0300

> There is a one byte hole between p->hop_limit and p->flowinfo where
> stack memory is leaked to the user.  This was introduced in c12b395a46
> "gre: Support GRE over IPv6".
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
