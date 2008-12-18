From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Wed, 17 Dec 2008 19:20:47 -0800 (PST)
Message-ID: <20081217.192047.117548302.davem@davemloft.net>
References: <200812172202.mBHM2GHi012456@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangchen@cn.fujitsu.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750947AbYLRDUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:20:46 -0500
In-Reply-To: <200812172202.mBHM2GHi012456@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 17 Dec 2008 22:02:16 GMT

> +	} else
> +		ppp_unlock(ppp);
> +
>  	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
>  	ppp->file.dead = 1;
>  	ppp->owner = NULL;

James, thanks for this fix.  But you'll need to respin this
as it conflicts with the IDR changes that are in net-next-2.6
(this cardmap_set call isn't there any more, for example).

Thanks.
