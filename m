From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] rps: Look into tunnels to get hash
Date: Wed, 17 Aug 2011 20:06:59 -0700 (PDT)
Message-ID: <20110817.200659.480003313920436612.davem@davemloft.net>
References: <alpine.DEB.2.00.1108142135340.24599@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab1HRDHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:07:02 -0400
In-Reply-To: <alpine.DEB.2.00.1108142135340.24599@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 14 Aug 2011 22:44:33 -0700 (PDT)

> In this version fixed calls to sock_rps_save_rxhash in IPv6 with correct
> arguments and addressed comments from Eric Dumazet.
> 
> The patches in this series are to look into encapsulated packets
> to compute the rx hash for RPS.  Before these patches, all packets
> received on the same tunnel would wind up on the same RPS CPU-- this
> can lead to very poor loading, and make RFS ineffective on these
> packets.
> 
> This patch supports getting the rxhash out of a GRE encapsulated packet.

I'm sure we'll have some follow-on tweaks to this, but the basic
infrastructure looks fine to me.

Applied, thanks!
