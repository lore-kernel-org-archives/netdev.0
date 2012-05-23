From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipx: restore token ring define to
 include/linux/ipx.h
Date: Wed, 23 May 2012 13:49:49 -0400 (EDT)
Message-ID: <20120523.134949.161940875949806704.davem@davemloft.net>
References: <1337784225-30641-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760655Ab2EWRtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 13:49:52 -0400
In-Reply-To: <1337784225-30641-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 23 May 2012 10:43:45 -0400

> Commit 211ed865108e24697b44bee5daac502ee6bdd4a4
> 
>     "net: delete all instances of special processing for token ring"
> 
> removed the define for IPX_FRAME_TR_8022.
> 
> While it is unlikely, we can't be 100% sure that there aren't
> random userspace consumers of this value, so restore it.
> 
> The only instance I could find was in ncpfs-2.2.6, and it was
> safe as-is, since it used #ifdef IPX_FRAME_TR_8022 around the
> two use cases it had, but there may be other userspace packages
> without similar ifdefs.
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
