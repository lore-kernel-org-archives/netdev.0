From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] udp: fix if statement in SIOCINQ ioctl
Date: Mon, 18 Apr 2016 13:40:39 -0400 (EDT)
Message-ID: <20160418.134039.321599420584841995.davem@davemloft.net>
References: <20160418084449.GA12410@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbcDRRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:40:47 -0400
In-Reply-To: <20160418084449.GA12410@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 18 Apr 2016 11:44:49 +0300

> We deleted a line of code and accidentally made the "return put_user()"
> part of the if statement when it's supposed to be unconditional.
> 
> Fixes: 9f9a45beaa96 ('udp: do not expect udp headers on ioctl SIOCINQ')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
