From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Add hw-switch-offload to
 netdev_features_strings.
Date: Fri, 20 Feb 2015 14:09:25 -0500 (EST)
Message-ID: <20150220.140925.830333854903707062.davem@davemloft.net>
References: <1424472648-24828-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756AbbBTTJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:09:27 -0500
In-Reply-To: <1424472648-24828-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat, 21 Feb 2015 00:50:48 +0200

> @@ -98,6 +98,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>  	[NETIF_F_RXALL_BIT] =            "rx-all",
>  	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
>  	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
> +        [NETIF_F_HW_SWITCH_OFFLOAD_BIT] = "hw-switch-offload",
>  };

This is definitely not indented properly.

The existing code uses a TAB character, you should too.
