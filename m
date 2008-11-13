From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 net-next] netdevice: safe convert to netdev_priv()
 #part-4
Date: Thu, 13 Nov 2008 00:01:32 -0800 (PST)
Message-ID: <20081113.000132.40213049.davem@davemloft.net>
References: <491B9469.7000905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751516AbYKMIBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 03:01:33 -0500
In-Reply-To: <491B9469.7000905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 13 Nov 2008 10:43:53 +0800

> We have some reasons to kill netdev->priv:
> 1. netdev->priv is equal to netdev_priv().
> 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
>    netdev_priv() is more flexible than netdev->priv.
> But we cann't kill netdev->priv, because so many drivers reference to it
> directly.
> 
> This patch is a safe convert for netdev->priv to netdev_priv(netdev).
> Since all of the netdev->priv is only for read.
> But it is too big to be sent in one mail.
> I split it to 4 parts and make every part smaller than 100,000 bytes,
> which is max size allowed by vger.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
