From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Fri, 25 Dec 2015 23:32:40 -0500 (EST)
Message-ID: <20151225.233240.1382574373461988831.davem@davemloft.net>
References: <1450996494-6811-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbLZEcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 23:32:42 -0500
In-Reply-To: <1450996494-6811-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 24 Dec 2015 14:34:54 -0800

> By moving stats update into iptunnel_xmit(), we can simplify
> iptunnel_xmit() usage. With this change there is no need to
> call another function (iptunnel_xmit_stats()) to update stats
> in tunnel xmit code path.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
