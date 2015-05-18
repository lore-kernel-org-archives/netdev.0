From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/1] hv_netvsc: change member name of struct
 netvsc_stats
Date: Sun, 17 May 2015 23:38:07 -0400 (EDT)
Message-ID: <20150517.233807.628743066804104408.davem@davemloft.net>
References: <1431682383-31240-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbERDiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:38:09 -0400
In-Reply-To: <1431682383-31240-1-git-send-email-sixiao@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixiao@microsoft.com>
Date: Fri, 15 May 2015 02:33:03 -0700

> Currently the struct netvsc_stats has a member s_sync
> of type u64_stats_sync.
> This definition will break kernel build as the macro
> netdev_alloc_pcpu_stats requires this member name to be syncp.
> (see netdev_alloc_pcpu_stats definition in ./include/linux/netdevice.h)
> 
> This patch changes netvsc_stats's member name from s_sync to syncp to fix
> the build break.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>

Applied, thanks.
