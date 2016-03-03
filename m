From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] UNIX sockets: POSIX conformance of errno's
Date: Thu, 03 Mar 2016 12:11:23 -0500 (EST)
Message-ID: <20160303.121123.722268631334039022.davem@davemloft.net>
References: <1457004216-24988-1-git-send-email-ed@nuxi.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ed@nuxi.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcCCRLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 12:11:25 -0500
In-Reply-To: <1457004216-24988-1-git-send-email-ed@nuxi.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Schouten <ed@nuxi.nl>
Date: Thu,  3 Mar 2016 12:23:36 +0100

> Hi there,
> 
> While comparing the behavior of the Berkeley sockets API different
> operating systems, I noticed that in some places we return different
> errno's as what POSIX requires and how other systems work, but also what
> we document in our own man pages.
> 
> This is the first time I'm sending a patch to the Linux kernel, so if
> there's anything wrong with the way I submitted these patches, just let
> me know.

I see very little to no value, if not harm, in doing this.

We've returned errors this way for two decades, and if there is code
out there checking the existing error codes it will break.

I really dislike blind POSIX/BSD/etc. "compliance" patches like this
because it completely ignores the decades of precedence our current
behavior has, upon which application might depend upon.

I'm not applying this series, sorry.
