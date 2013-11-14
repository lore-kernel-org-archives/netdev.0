From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti/cpsw: do not crash on single-MAC
 machines during resume
Date: Thu, 14 Nov 2013 16:21:21 -0500 (EST)
Message-ID: <20131114.162121.1914559247437932528.davem@davemloft.net>
References: <1384347180-3490-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab3KNVVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:21:24 -0500
In-Reply-To: <1384347180-3490-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Wed, 13 Nov 2013 13:53:00 +0100

> To prevent Oopses, cpsw_suspend() should only soft-reset sliver 1
> on dual MAC enabled machines.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Please reimplement this using for_each_slave() as Mungunthan suggested.

Thanks.
