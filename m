From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] v3 GRE: TCP segmentation offload
Date: Fri, 15 Feb 2013 15:18:24 -0500 (EST)
Message-ID: <20130215.151824.1125629773152171791.davem@davemloft.net>
References: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3BOUS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:18:28 -0500
In-Reply-To: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 14 Feb 2013 11:44:41 -0800

> Following patches add TCP segmentation offload to GRE. These 
> patches shows 20-25% performance improvement in netperf single
> process TCP_STREAM test on 10G network.
> 
> Pravin B Shelar (3):
>   net: Add skb_unclone() helper function.
>   net: factor out skb_mac_gso_segment() from skb_gso_segment()
>   GRE: Add TCP segmentation offload for GRE

All applied, incorporating the suggestions/fixes from Eric.  Specifically,
using skb_reset_mac_len() in patch #2 and computing pkt_len before ip_local_out()
in patch #3.

Thanks.
