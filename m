From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: addrconf: validate new MTU before
 applying it
Date: Mon, 23 Feb 2015 18:16:45 -0500 (EST)
Message-ID: <20150223.181645.1582799387342364278.davem@davemloft.net>
References: <463ebd12cf29ddcf17275bdde9fb629444a5fa5b.1424698335.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbBWXQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 18:16:47 -0500
In-Reply-To: <463ebd12cf29ddcf17275bdde9fb629444a5fa5b.1424698335.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Mon, 23 Feb 2015 11:17:13 -0300

> Currently we don't check if the new MTU is valid or not and this allows
> one to configure a smaller than minimum allowed by RFCs or even bigger
> than interface own MTU, which is a problem as it may lead to packet
> drops.
> 
> If you have a daemon like NetworkManager running, this may be exploited
> by remote attackers by forging RA packets with an invalid MTU, possibly
> leading to a DoS. (NetworkManager currently only validates for values
> too small, but not for too big ones.)
> 
> The fix is just to make sure the new value is valid. That is, between
> IPV6_MIN_MTU and interface's MTU.
> 
> Note that similar check is already performed at
> ndisc_router_discovery(), for when kernel itself parses the RA.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Applied, thanks.
