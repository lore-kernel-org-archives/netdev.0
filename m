From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: Fix handling of skbs requiring too
 many slots
Date: Wed, 11 Jun 2014 12:17:18 -0700 (PDT)
Message-ID: <20140611.121718.38978941694087173.davem@davemloft.net>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com>
	<53984D58.7010708@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, linux@eikelenboom.it,
	netdev@vger.kernel.org, david.vrabel@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaFKTRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 15:17:19 -0400
In-Reply-To: <53984D58.7010708@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 11 Jun 2014 13:36:40 +0100

> This patch have made the net and net-next trees already, but not the
> mainline 3.15. That's unfortunate, because just 2 days after someone
> already spotted the problem (see "netback oops in Linux 3.14 / 3.15"
> on xen-devel)
> David, should I resend the patch for stable maintaners to include it
> in the 3.15 stable branch?

Networking patches are submitted to -stable by me, so you have to ask
me explicitly to queue it up.

Note that I do try to let patches "cook" in the networking tree for
some time before I send them off to -stable, this can be up to two
weeks.
