From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: fix bridge notify hook to manage flags
 correctly
Date: Sat, 03 Nov 2012 15:38:43 -0400 (EDT)
Message-ID: <20121103.153843.901543682940611340.davem@davemloft.net>
References: <20121103023236.8177.63714.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab2KCTio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:38:44 -0400
In-Reply-To: <20121103023236.8177.63714.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 02 Nov 2012 19:32:36 -0700

> The bridge notify hook rtnl_bridge_notify() was not handling the
> case where the master flags was set or with both flags set. First
> flags are not being passed correctly and second the logic to parse
> them is broken.
> 
> This patch passes the original flags value and fixes the
> logic.
> 
> Reported-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
