From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4 tunnels: fix an oops when using ipip/sit with
 IPsec
Date: Fri, 30 Aug 2013 17:14:15 -0400 (EDT)
Message-ID: <20130830.171415.1757619806522159250.davem@davemloft.net>
References: <1377683690-4506-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, hongjun.li@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab3H3VRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:17:39 -0400
In-Reply-To: <1377683690-4506-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 28 Aug 2013 11:54:50 +0200

> From: Li Hongjun <hongjun.li@6wind.com>
> 
> Since commit 3d7b46cd20e3 (ip_tunnel: push generic protocol handling to
> ip_tunnel module.), an Oops is triggered when an xfrm policy is configured on
> an IPv4 over IPv4 tunnel.
> 
> xfrm4_policy_check() calls __xfrm_policy_check2(), which uses skb_dst(skb). But
> this field is NULL because iptunnel_pull_header() calls skb_dst_drop(skb).
> 
> Signed-off-by: Li Hongjun <hongjun.li@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks everyone.
