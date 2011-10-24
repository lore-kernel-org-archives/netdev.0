From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Do not use routes from locally generated RAs
Date: Mon, 24 Oct 2011 18:37:15 -0400 (EDT)
Message-ID: <20111024.183715.460582802706449552.davem@davemloft.net>
References: <1319388071-21323-1-git-send-email-andi@collax.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@collax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab1JXWhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 18:37:38 -0400
In-Reply-To: <1319388071-21323-1-git-send-email-andi@collax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Hofmeister <andi@collax.com>
Date: Sun, 23 Oct 2011 18:41:11 +0200

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

Please make a fresh full resubmission of this patch and add an
appropriate Signed-off-by: tag to your commit message.

Thanks.
