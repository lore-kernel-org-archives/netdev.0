From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: Work around invalid MAC address error
Date: Wed, 09 Mar 2011 13:44:36 -0800 (PST)
Message-ID: <20110309.134436.28819615.davem@davemloft.net>
References: <4D77F253.5010908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rl@hellgate.ch, florian@openwrt.org
To: mr.nuke.me@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53520
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab1CIVn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:43:59 -0500
In-Reply-To: <4D77F253.5010908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alex G." <mr.nuke.me@gmail.com>
Date: Wed, 09 Mar 2011 23:34:11 +0200

> via-rhine drops out of the init code if the hardware provides an invalid
> MAC address. Roger Luethi has had several reports of Rhine NICs doing just
> that. The hardware still works, though; assigning a random MAC address
> allows the NIC to be used as usual. Tested as a standalone interface,
> as carrier for ppp, and as bonding slave.
> 
> Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>
> 
> diff --git a/drivers/net/via-rhine.c.orig b/drivers/net/via-rhine.c
> index 4930f9d..4c1b9e7 100644
> --- a/drivers/net/via-rhine.c.orig
> +++ b/drivers/net/via-rhine.c

This is getting rediculious:

davem@sunset:~/src/GIT/net-2.6$ git apply --check --whitespace=error-all via-rhine-Work-around-invalid-MAC-address-error.patch
error: drivers/net/via-rhine.c.orig: No such file or directory
davem@sunset:~/src/GIT/net-2.6$ 
davem@sunset:~/src/GIT/net-2.6$ git am --signoff via-rhine-Work-around-invalid-MAC-address-error.patch 
Applying: via-rhine: Work around invalid MAC address error
error: drivers/net/via-rhine.c.orig: does not exist in index
Patch failed at 0001 via-rhine: Work around invalid MAC address error
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
You have new mail in /var/mail/davem
davem@sunset:~/src/GIT/net-2.6$ git am --abort

Sorry.

I'm going to ignore you're postings for a day or two, I've already
invested an enormous amount of time and energy into getting you to
submit patches which are properly formed and actually get accepted by
the tools that we all use.  Nobody else has these kinds of problems
and can submit properly formed patches.

I would strongly suggest that you try to email the patch to yourself,
save the email into a file, and feed it to "git am" on a fresh tree,
making sure that when then looking at what the resulting commit looks
like.
