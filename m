From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 16/18] netdevice zd1201: Convert directly reference of
	netdev->priv to netdev->ml_priv
Date: Fri, 5 Sep 2008 08:56:27 -0400
Message-ID: <20080905125626.GB3027@tuxdriver.com>
References: <48C0A219.2030004@cn.fujitsu.com> <48C0A7A0.9030200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35550 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbYIENAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 09:00:36 -0400
Content-Disposition: inline
In-Reply-To: <48C0A7A0.9030200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 11:29:36AM +0800, Wang Chen wrote:
> We have some reasons to kill netdev->priv:
> 1. netdev->priv is equal to netdev_priv().
> 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
>    netdev_priv() is more flexible than netdev->priv.
> But we cann't kill netdev->priv, because so many drivers reference to it
> directly.
> 
> OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> and I want to kill netdev->priv later, I decided to convert all the direct
> reference of netdev->priv first.
> 
> Different to readonly reference of netdev->priv, in this driver, netdev->priv
> was changed. I use netdev->ml_priv to replace netdev->priv.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Same comment as the other patch.

Also, I have to be honest and say that I had never been aware of
dev->ml_priv before, so I'm not entirely sure what it is.  However,
from the comment at it's definision ("mid-layer private") and it's
usage in qeth, loopback, and ppp, I'm not at all sure that you are
using it as intended.

Can you explain?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
