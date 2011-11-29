From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: do not scale TSO segment size with reordering
 degree
Date: Tue, 29 Nov 2011 01:20:03 -0500 (EST)
Message-ID: <20111129.012003.1740760661042581397.davem@davemloft.net>
References: <1321931714-28176-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, hkchu@google.com,
	therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab1K2GUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:20:18 -0500
In-Reply-To: <1321931714-28176-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 21 Nov 2011 22:15:14 -0500

> Since 2005 (c1b4a7e69576d65efc31a8cea0714173c2841244)
> tcp_tso_should_defer has been using tcp_max_burst() as a target limit
> for deciding how large to make outgoing TSO packets when not using
> sysctl_tcp_tso_win_divisor. But since 2008
> (dd9e0dda66ba38a2ddd1405ac279894260dc5c36) tcp_max_burst() returns the
> reordering degree. We should not have tcp_tso_should_defer attempt to
> build larger segments just because there is more reordering. This
> commit splits the notion of deferral size used in TSO from the notion
> of burst size used in cwnd moderation, and returns the TSO deferral
> limit to its original value.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next.
