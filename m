From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig wait for carrier
Date: Mon, 16 May 2011 14:02:06 -0400 (EDT)
Message-ID: <20110516.140206.663523943138508667.davem@davemloft.net>
References: <1305405386-25187-1-git-send-email-micha@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab1EPSCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 14:02:09 -0400
In-Reply-To: <1305405386-25187-1-git-send-email-micha@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Sat, 14 May 2011 22:36:26 +0200

> Currently the ip auto configuration has a hardcoded delay of 1 second.
> When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
> nfs root may not be found.
> 
> Remove the hardcoded delay, and wait for carrier on at least one network
> device.

Again, you are missing a proper "Signed-off-by: " line, also:

> 
> Index: atom-linux/net/ipv4/ipconfig.c
> ===================================================================
> --- atom-linux/net/ipv4/ipconfig.c	(revision 1445)
> +++ atom-linux/net/ipv4/ipconfig.c	(working copy)

I'm not taking patches which are against some random atom-linux tree,
you have to make your patches against the current upstream sources
only.
