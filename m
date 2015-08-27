From: David Miller <davem@davemloft.net>
Subject: Re: [TRIVIAL PATCH V2] smsc9194: Remove uncompilable #if 0'd use
 of pr_dbg
Date: Thu, 27 Aug 2015 13:56:59 -0700 (PDT)
Message-ID: <20150827.135659.911837443118015481.davem@davemloft.net>
References: <1440614975.2780.40.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbH0U5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 16:57:00 -0400
In-Reply-To: <1440614975.2780.40.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 26 Aug 2015 11:49:35 -0700

> No pr_dbg method exists.
> 
> While this code is #if 0'd, it'd be nicer to
> use the generic hex_dump, so use it instead.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next, thanks Joe.

I don't know what to do with "really old" drivers.  People still use
them, some via qemu or whatever.

But yeah this particular case is likely unused by anyone.
