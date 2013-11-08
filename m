From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] ipv6: increase maximum lifetime of flow
 labels
Date: Fri, 08 Nov 2013 13:44:40 -0500 (EST)
Message-ID: <20131108.134440.189022097003195180.davem@davemloft.net>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1383843194-22945-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932149Ab3KHSom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:44:42 -0500
In-Reply-To: <1383843194-22945-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Thu,  7 Nov 2013 17:53:13 +0100

> If the last RFC 6437 does not give any constraints
> for lifetime of flow labels, the previous RFC 3697
> spoke of a minimum of 120 seconds between
> reattribution of a flow label.
> 
> The maximum linger is currently set to 60 seconds
> and does not allow this configuration without
> CAP_NET_ADMIN right.
> 
> This patch increase the maximum linger to 150
> seconds, allowing more flexibility to standard
> users.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
