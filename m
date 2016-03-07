From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: release rtnl mutex when interface creation
 fails
Date: Mon, 07 Mar 2016 16:12:19 -0500 (EST)
Message-ID: <20160307.161219.1996879197422638975.davem@davemloft.net>
References: <cde1cd85393f3a2f0900b7c2ec6ed5f615783351.1457375501.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbcCGVMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 16:12:21 -0500
In-Reply-To: <cde1cd85393f3a2f0900b7c2ec6ed5f615783351.1457375501.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 7 Mar 2016 19:36:44 +0100

> Add missing rtnl_unlock() in the error path of ppp_create_interface().
> 
> Fixes: 58a89ecaca53 ("ppp: fix lockdep splat in ppp_dev_uninit()")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
