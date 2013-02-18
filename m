From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix warning in xfrm6_mode_tunnel_input
Date: Mon, 18 Feb 2013 12:43:10 -0500 (EST)
Message-ID: <20130218.124310.1465119116562073604.davem@davemloft.net>
References: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158Ab3BRRnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:43:12 -0500
In-Reply-To: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 16 Feb 2013 09:38:15 -0800

> Should not use assignment in conditional:
>  warning: suggest parentheses around assignment used as truth value [-Wparentheses]
> 
> Problem introduced by:
> commit 14bbd6a565e1bcdc240d44687edb93f721cfdf99
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Thu Feb 14 09:44:49 2013 +0000
> 
>     net: Add skb_unclone() helper function.
>     
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
