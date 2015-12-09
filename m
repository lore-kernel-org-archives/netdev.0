From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: Fix IPv6 xmit stats update.
Date: Tue, 08 Dec 2015 22:39:19 -0500 (EST)
Message-ID: <20151208.223919.288650191576863965.davem@davemloft.net>
References: <1449544650-6112-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbLIDjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:39:23 -0500
In-Reply-To: <1449544650-6112-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon,  7 Dec 2015 19:17:30 -0800

> Call to iptunnel_xmit_stats() is not required after udp-tunnel6-xmit.
> By calling iptunnel_xmit_stats() results in incorrect device stats.
> Following patch drops this call.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks Pravin.
