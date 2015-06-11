From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/ethtool: Add current supported tunable
 options
Date: Wed, 10 Jun 2015 22:07:25 -0700 (PDT)
Message-ID: <20150610.220725.1836894008272332422.davem@davemloft.net>
References: <1433863794-40982-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, amirv@mellanox.com,
	ogerlitz@mellanox.com, talal@mellanox.com, _govind@gmx.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbFKFH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:07:26 -0400
In-Reply-To: <1433863794-40982-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Tue,  9 Jun 2015 18:29:54 +0300

> Add strings array of the current supported tunable options.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reviewed-by: Amir Vadai <amirv@mellanox.com>
> ---
>  include/uapi/linux/ethtool.h |  6 ++++++
>  net/core/ethtool.c           | 12 ++++++++++++
>  2 files changed, 18 insertions(+)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 0594933..90e4bff 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -215,6 +215,11 @@ enum tunable_id {
>  	ETHTOOL_ID_UNSPEC,
>  	ETHTOOL_RX_COPYBREAK,
>  	ETHTOOL_TX_COPYBREAK,
> +	/*
> +	 * Add your fresh new tubale attribute above and remember to update
> +	 * tunable_strings[] in net/core/ethtool.c
> +	 */
> +	ETHTOOL_TUNABLE_COUNT,
>  };
>  
>  enum tunable_type_id {

Please put two leading underscores in the name of this enumeration
to make it clear that it is an implementation internal value that
users should not try to use.  F.e. __ETHTOOL_TUNABLE_COUNT
