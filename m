From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: make the net.ipv6.conf.all.use_tempaddr sysctl
 propagate to interface settings
Date: Mon, 19 Dec 2011 16:16:24 -0500 (EST)
Message-ID: <20111219.161624.488823593081231376.davem@davemloft.net>
References: <1324071933-2961-1-git-send-email-mathieu.trudel-lapierre@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mathieu.trudel-lapierre@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab1LSVTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:19:18 -0500
In-Reply-To: <1324071933-2961-1-git-send-email-mathieu.trudel-lapierre@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Trudel-Lapierre <mathieu.trudel-lapierre@canonical.com>
Date: Fri, 16 Dec 2011 16:45:33 -0500

> The description for IPV6_PRIVACY mentions using .../all/use_tempaddr to enable
> IPv6 Privacy Extensions, and IP sysctl documentation mentions 'all' as setting
> all interface-specific settings. We make sure at least use_tempaddr actually
> works as documented.
> 
> Signed-off-by: Mathieu Trudel-Lapierre <mathieu.trudel-lapierre@canonical.com>

"all" settings must be in place before the device is created and comes up.

You can't just "propagate" to the existing devices when the "all"
setting is changed, because an individual device might have had it's
independent sysctl setting modified by the administrator and you'll be
smashing that.

I'm not applying this patch.
