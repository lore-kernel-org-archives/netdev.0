From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Convert IRDA_DEBUG to pr_debug
Date: Wed, 12 Nov 2014 13:57:19 -0500 (EST)
Message-ID: <20141112.135719.707307878615480184.davem@davemloft.net>
References: <20141111.162257.701721486580745428.davem@davemloft.net>
	<1415741850.16070.13.camel@perches.com>
	<1415745897.16070.15.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbaKLS5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 13:57:22 -0500
In-Reply-To: <1415745897.16070.15.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Nov 2014 14:44:57 -0800

> Use the normal kernel debugging mechanism which also
> enables dynamic_debug at the same time.
> 
> Other miscellanea:
> 
> o Remove sysctl for irda_debug
> o Remove function tracing like uses (use ftrace instead)
> o Coalesce formats
> o Realign arguments
> o Remove unnecessary OOM messages
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> donauboe does not have normal indentation, unchanged.

Applied to net-next, thanks Joe.
