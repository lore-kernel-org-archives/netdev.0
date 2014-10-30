From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Thu, 30 Oct 2014 16:09:36 -0400 (EDT)
Message-ID: <20141030.160936.373944710383391596.davem@davemloft.net>
References: <1414563898-10347-1-git-send-email-alan@al-an.info>
	<1414569292-15384-1-git-send-email-alan@al-an.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: alan@al-an.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513AbaJ3UJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:09:38 -0400
In-Reply-To: <1414569292-15384-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexey Andriyanov" <alan@al-an.info>
Date: Wed, 29 Oct 2014 10:54:52 +0300

> The fallback device is in ipv6 mode by default.
> The mode can not be changed in runtime, so there
> is no way to decapsulate ip4in6 packets coming from
> various sources without creating the specific tunnel
> ifaces for each peer.
> 
> This allows to update the fallback tunnel device, but only
> the mode could be changed. Usual command should work for the
> fallback device: `ip -6 tun change ip6tnl0 mode any`
> 
> The fallback device can not be hidden from the packet receiver
> as a regular tunnel, but there is no need for synchronization
> as long as we do single assignment.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexey Andriyanov <alan@al-an.info>

Applied to net-next, thanks.
