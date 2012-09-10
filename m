From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: netlink: hide struct module parameter in netlink_kernel_create
Date: Mon, 10 Sep 2012 09:45:35 +0200
Message-ID: <20120910074535.GA32043@1984>
References: <20120910093712.18e5718b605f84aa4e76f7d9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58241 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab2IJHpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 03:45:39 -0400
Content-Disposition: inline
In-Reply-To: <20120910093712.18e5718b605f84aa4e76f7d9@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 10, 2012 at 09:37:12AM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> I didn't see the original patch until it reached linux-enxt this morning,
> but just a comment:
> 
> THIS_MODULE is defined in linux/export.h, so that should be included in
> linux/netlink.h instead of linux/module.h as it is much smaller.

I'll send a follow-up patch for this to David, thanks Stephen.
