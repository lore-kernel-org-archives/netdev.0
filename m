From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] inet_diag: Fix old/new inet_diag_req-s structures
Date: Wed, 11 Jan 2012 12:58:13 -0800 (PST)
Message-ID: <20120111.125813.546007433493549448.davem@davemloft.net>
References: <4F0D49D4.7040100@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab2AKU6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 15:58:18 -0500
In-Reply-To: <4F0D49D4.7040100@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 11 Jan 2012 12:35:32 +0400

> The recent changes to inet_diag broke the compilation of tools using kernel headers.
> 
> Fix this by doing two sequential renames:
> 
>  inet_diag_req -> inet_diag_req_v2
>  inet_diag_req_compat -> inet_diag_req
> 
> After this the changes in the user-space visible part of the inet_diag.h are
> * add the inet_diag_req_v2
> * extend the INET_DIAG_ extensions list
> 
> The set applies to current net tree.

Both applied, thanks.

> David, Stephen, I'm a little bit confused with the situation with this header. Can
> you please comment on the (quite ancient) commit 73c1f4a0 ([TCPDIAG]: Just rename 
> everything to inet_diag) from acme@? This commit did the similar thing with inet_diag
> header -- flushed away the old struct and introduced a new one keeping just the binary
> compatibility. Why was the breakage of tools caused by this commit considered as 
> acceptable?

Sigh... we simply didn't notice it back then, and that's the end of
it.  Can you please stop bringing up this point now?  Thanks.
