From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Reorder initialization in ip_route_output to fix
 gcc warning
Date: Sun, 10 Jun 2012 23:44:11 -0700 (PDT)
Message-ID: <20120610.234411.850948486629299757.davem@davemloft.net>
References: <1339394724-28296-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab2FKGoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 02:44:14 -0400
In-Reply-To: <1339394724-28296-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Sun, 10 Jun 2012 23:05:24 -0700

> From: Roland Dreier <roland@purestorage.com>
> 
> If I build with W=1, for every file that includes <net/route.h>, I get the warning
> 
>     include/net/route.h: In function 'ip_route_output':
>     include/net/route.h:135:3: warning: initialized field overwritten [-Woverride-init]
>     include/net/route.h:135:3: warning: (near initialization for 'fl4') [-Woverride-init]
> 
> (This is with "gcc (Debian 4.6.3-1) 4.6.3")
> 
> A fix seems pretty trivial: move the initialization of .flowi4_tos
> earlier.  As far as I can tell, this has no effect on code generation.
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>

I can't figure out what it is actually warning about, can you?
