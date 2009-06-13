From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/07: netfilter update
Date: Sat, 13 Jun 2009 16:53:48 -0700 (PDT)
Message-ID: <20090613.165348.209715007.davem@davemloft.net>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753105AbZFMXxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 19:53:46 -0400
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 13 Jun 2009 15:09:34 +0200 (MEST)

> following is a final netfilter update for 2.6.31, containing:
> 
> - a fix for a warning when reading one of the the nf_log files
> 
> - a patch to use the new mod_timer_pending() function in conntrack
>   to avoid taking the global conntrack lock for timer updates
> 
> - a set of patches from Pablo to make conntrack event notifications
>   runtime selectable and optionally reliable. This works by making
>   sure at least the final destroy event is successfully transmitted,
>   otherwise the event is re-broadcast until a configurable timeout
>   is reached.
> 
> - a patch from Joe Perches to convert a bunch of printks without a
>   log level to pr_err()
> 
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Pulled, thanks a lot Patrick.
