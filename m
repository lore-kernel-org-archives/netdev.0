From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bonding: Introduce 4 AD link speed
Date: Fri, 21 Nov 2014 17:16:13 -0500 (EST)
Message-ID: <20141121.171613.504119260083729947.davem@davemloft.net>
References: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net
To: Jianhua.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbaKUWQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 17:16:15 -0500
In-Reply-To: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Jianhua <Jianhua.Xie@freescale.com>
Date: Wed, 19 Nov 2014 16:48:57 +0800

> From: Jianhua Xie <Jianhua.Xie@freescale.com>
> 
> The speed field of AD Port Key was based on bitmask, it supported 5
> kinds of link speed at most, as there were only 5 bits in the speed
> field of the AD Port Key.  This patches series change the speed type
> (AD_LINK_SPEED_BITMASK) from bitmask to enum type in order to enhance
> speed type from 5 to 32, and then introduce 4 AD link speed to fix
> agg_bandwidth.
> 
> Jianhua Xie (2):
>   bonding: change AD_LINK_SPEED_BITMASK to enum to suport more speed
>   bonding: Introduce 4 AD link speed to fix agg_bandwidth
> 
>  drivers/net/bonding/bond_3ad.c | 102 ++++++++++++++++++++++++++++-------------
>  1 file changed, 70 insertions(+), 32 deletions(-)
> 
> -- 
> v2:
>  * Use an enum type to instead of the bitmask, not expand speed field, 
> 
> v1:
>  * Compress RFC patches #2 to #5 into one single patch.
>  * Fix inexact commit information.

Series applied, thanks.
