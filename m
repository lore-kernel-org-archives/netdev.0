From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: remove an unneeded check
Date: Tue, 30 Jul 2013 19:24:42 -0700 (PDT)
Message-ID: <20130730.192442.636351467466486145.davem@davemloft.net>
References: <20130729191519.GA11874@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab3GaCYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:24:43 -0400
In-Reply-To: <20130729191519.GA11874@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 29 Jul 2013 22:15:19 +0300

> "ifa->ifa_label" is an array inside the in_ifaddr struct.  It can never
> be NULL so we can remove this check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Yeah this has been like this forever, applied to net-next, thanks
Dan.
