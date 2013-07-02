From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnels: Use skb-len to PMTU check.
Date: Tue, 02 Jul 2013 16:44:30 -0700 (PDT)
Message-ID: <20130702.164430.2268054114415286435.davem@davemloft.net>
References: <1372787853-12382-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3GBXob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 19:44:31 -0400
In-Reply-To: <1372787853-12382-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue,  2 Jul 2013 10:57:33 -0700

> In path mtu check, ip header total length works for gre device
> but not for gre-tap device.  Use skb len which is consistent
> for all tunneling types.  This is old bug in gre.
> This also fixes mtu calculation bug introduced by
> commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).
> 
> Reported-by: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied and queued up for -stable, thanks!
