From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Make 'addrconf_rs_timer' send Router
 Solicitations (and re-arm itself) if Router Advertisements are accepted
Date: Mon, 03 Dec 2012 14:00:19 -0500 (EST)
Message-ID: <20121203.140019.1575288073278302679.davem@davemloft.net>
References: <1354448693-32155-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	tore@fud.no, amikoren@yahoo.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2LCTAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 14:00:21 -0500
In-Reply-To: <1354448693-32155-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Sun,  2 Dec 2012 13:44:53 +0200

> As of 026359b [ipv6: Send ICMPv6 RSes only when RAs are accepted],
> Router Solicitations are sent whenever kernel accepts Router
> Advertisements on the interface.
> 
> However, this logic isn't reflected in 'addrconf_rs_timer'.
> 
> The timer fails to issue subsequent RS messages (and fails to re-arm
> itself) if forwarding is enabled and the special hybrid mode is
> enabled (accept_ra=2).
> 
> Fix the condition determining whether next RS should be sent, by using
> 'ipv6_accept_ra()'.
> 
> Reported-by: Ami Koren <amikoren@yahoo.com>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.
