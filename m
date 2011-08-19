From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix ipv6_getsockopt for IPV6_2292PKTOPTIONS
Date: Fri, 19 Aug 2011 03:19:57 -0700 (PDT)
Message-ID: <20110819.031957.1143398061283788162.davem@davemloft.net>
References: <1313747758-10063-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, sdumitru@ixiacom.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab1HSKVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:21:44 -0400
In-Reply-To: <1313747758-10063-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <dbaluta@ixiacom.com>
Date: Fri, 19 Aug 2011 12:55:58 +0300

> IPV6_2292PKTOPTIONS is broken for 32-bit applications running
> in COMPAT mode on 64-bit kernels.
> 
> The same problem was fixed for IPv4 with the patch:
> ipv4: Fix ip_getsockopt for IP_PKTOPTIONS,
> commit dd23198e58cd35259dd09e8892bbdb90f1d57748
> 
> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>

Applied, but:

> -	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
> +	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen, 

This adds trailing whitespace, which GIT catches and warns about,
please be mindful of this in the future.

I took care of it and fixed it up this time.
