From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV6: fix source address selection
Date: Sun, 16 Sep 2007 14:49:01 -0700 (PDT)
Message-ID: <20070916.144901.10307496.davem@davemloft.net>
References: <Pine.LNX.4.64.0709130044300.7343@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, jbohac@suse.cz,
	pasky@suse.cz
To: jkosina@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:57265
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753017AbXIPVt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 17:49:59 -0400
In-Reply-To: <Pine.LNX.4.64.0709130044300.7343@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Thu, 13 Sep 2007 00:56:00 +0200 (CEST)

> From: Jiri Kosina <jkosina@suse.cz>
> 
> [PATCH] IPV6: fix source address selection
> 
> The commit 95c385 broke proper source address selection for cases in which 
> there is a address which is makred 'deprecated'. The commit mistakenly 
> changed ifa->flags to ifa_result->flags (probably copy/paste error from a 
> few lines above) in the 'Rule 3' address selection code.
> 
> The patch below restores the previous RFC-compliant behavior, please 
> apply.
> 
> Cc: Jiri Bohac <jbohac@suse.cz>
> Cc: Petr Baudis <pasky@suse.cz>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Excellent catch Jiri.

I'll apply this and push to -stable as well.

Thanks a lot!
