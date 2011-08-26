From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] Fix net header dependencies
Date: Fri, 26 Aug 2011 12:09:47 -0400 (EDT)
Message-ID: <20110826.120947.931880007743069150.davem@davemloft.net>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab1HZQJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:09:56 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 25 Aug 2011 05:38:44 +0100

> Various networking headers depend on definitions from others which they
> don't include.  We can't fix all of these, because some definitions are
> duplicated between kernel headers and glibc headers and we cannot tell
> which is the right one to include.  We also have to be wary of
> introducing a dependency cycle.
> 
> Since v1, I've dropped the patches to <linux/scc.h> and <linux/if_ppp.h>
> and added the acknowledgements I got last time.

All applied, thanks!
