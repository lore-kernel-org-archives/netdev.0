From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Do not use routes from locally generated RAs
Date: Mon, 24 Oct 2011 19:13:31 -0400 (EDT)
Message-ID: <20111024.191331.2212247007501044514.davem@davemloft.net>
References: <1319497776-23998-1-git-send-email-andi@collax.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@collax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab1JXXNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 19:13:48 -0400
In-Reply-To: <1319497776-23998-1-git-send-email-andi@collax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Hofmeister <andi@collax.com>
Date: Tue, 25 Oct 2011 01:09:36 +0200

> When hybrid mode is enabled (accept_ra == 2), the kernel also sees RAs
> generated locally. This is useful since it allows the kernel to auto-configure
> its own interface addresses.
> 
> However, if 'accept_ra_defrtr' and/or 'accept_ra_rtr_pref' are set and the
> locally generated RAs announce the default route and/or other route information,
> the kernel happily inserts bogus routes with its own address as gateway.
> 
> With this patch, adding routes from an RA will be skiped when the RAs source
> address matches any local address, just as if 'accept_ra_defrtr' and
> 'accept_ra_rtr_pref' were set to 0.
> 
> Signed-off-by: Andreas Hofmeister <andi@collax.com>

Applied, thanks.
