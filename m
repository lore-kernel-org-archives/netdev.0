From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Simplify IRDA logging macros
Date: Tue, 11 Nov 2014 16:22:57 -0500 (EST)
Message-ID: <20141111.162257.701721486580745428.davem@davemloft.net>
References: <1415740421.16070.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaKKVXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:23:00 -0500
In-Reply-To: <1415740421.16070.11.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Nov 2014 13:13:41 -0800

> These are the same as net_<level>_ratelimited, so
> use the more common style in the macro definition.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.

> I wonder if the IRDA_ macro uses should be converted
> directly instead but that diffstat is quite a bit
> longer than this one

You can do that as a follow-on patch if you want.  Macros
that just provide another name for a well understood generic
facility are really something to get rid of.
