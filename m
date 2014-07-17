From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Update setapp/getapp prototypes in
 dcbnl_rtnl_ops to return int instead of u8
Date: Wed, 16 Jul 2014 22:23:03 -0700 (PDT)
Message-ID: <20140716.222303.1286422592325268399.davem@davemloft.net>
References: <1405571974-23143-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	dan.carpenter@oracle.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbaGQFXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 01:23:05 -0400
In-Reply-To: <1405571974-23143-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 16 Jul 2014 21:39:34 -0700

> @@ -472,6 +472,8 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
>  
>  	if (netdev->dcbnl_ops->getapp) {
>  		up = netdev->dcbnl_ops->getapp(netdev, idtype, id);
> +		if (up < 0)
> +			return up;
>  	} else {
>  		struct dcb_app app = {
>  					.selector = idtype,

'up' is u8 so can never be less than zero.
