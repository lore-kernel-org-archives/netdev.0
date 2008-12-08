From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] netdevice: Kill netdev->priv
Date: Mon, 08 Dec 2008 01:14:28 -0800 (PST)
Message-ID: <20081208.011428.198068992.davem@davemloft.net>
References: <493CB23A.5010400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751054AbYLHJO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:14:27 -0500
In-Reply-To: <493CB23A.5010400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 08 Dec 2008 13:35:54 +0800

> This is the last shoot of this series.
> After I removing all directly reference of netdev->priv, I am killing
> "priv" of "struct net_device" and fixing relative comments/docs.
> 
> Anyone will not be allowed to reference netdev->priv directly.
> If you want to reference the memory of private data, use netdev_priv()
> instead.
> If the private data is not allocted when alloc_netdev(), use
> netdev->ml_priv to point that memory after you creating that private
> data.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.

Thanks so much for doing all of this work!
