From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: do not create neighbor entries for local delivery
Date: Wed, 16 Jan 2013 16:28:13 -0500 (EST)
Message-ID: <20130116.162813.1734293658687337225.davem@davemloft.net>
References: <50F6ABCA.4020804@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757016Ab3APV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:28:15 -0500
In-Reply-To: <50F6ABCA.4020804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Wed, 16 Jan 2013 11:31:54 -0200

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index
> 7c34c01b515b7ac370f8021ba6f5ec4c654e9e41..b63e33bcbdfbc1bd78af0b98ffc2d211805214ea
> 100644

Patch corrupted by your email client.

Note also that YOSHIFUJI Hideaki's patches to remove the cached neighbour
entirely from ipv6 routes will have the same effect, so your patch won't
be needed.
