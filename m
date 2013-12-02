From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: source address selection, Rule 7:
 Prefer temporary addresses (RFC 6724)
Date: Sun, 01 Dec 2013 20:22:37 -0500 (EST)
Message-ID: <20131201.202237.1289362147164597952.davem@davemloft.net>
References: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab3LBBWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:22:38 -0500
In-Reply-To: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fx.lebail@yahoo.com
Date: Mon, 25 Nov 2013 17:16:45 +0100

> The RFC 6724 change the default recommendation for source address selection
> Rule 7 to prefer temporary addresses rather than public addresses,
> while providing an administrative override.
> 
> The administrative override is based on the prefer_src_public sysctl.
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

I think we need to preserve existing behavior, but this patch does not
do that.

Sorry, I can't apply this.

If someone was depending upon the old preferencing in some way, we will
break communications for them, and that really isn't acceptable.

It's really ill advised for the RFC folks to create situations like
this, where implementations have to choose between following the
updated RFC to the letter and keeping existing setups working.
