From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Tue, 08 Dec 2015 22:41:20 -0500 (EST)
Message-ID: <20151208.224120.451853113571251140.davem@davemloft.net>
References: <1449631354-3701-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbLIDlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:41:21 -0500
In-Reply-To: <1449631354-3701-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue,  8 Dec 2015 19:22:34 -0800

> By moving stats update into iptunnel_xmit(), we can simplify
> iptunnel_xmit() usage. With this change there is no need to
> call another function (iptunnel_xmit_stats()) to update stats
> in tunnel xmit code path.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

You're going to have to respin this relative to the fix I just
put into 'net'.
