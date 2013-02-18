From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a compile error when SOCK_REFCNT_DEBUG is
 enabled
Date: Mon, 18 Feb 2013 12:31:37 -0500 (EST)
Message-ID: <20130218.123137.2068004635468705026.davem@davemloft.net>
References: <1361003305-1198-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253Ab3BRRbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:31:39 -0500
In-Reply-To: <1361003305-1198-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Sat, 16 Feb 2013 16:28:25 +0800

> When SOCK_REFCNT_DEBUG is enabled, below build error is met:
> 
> kernel/sysctl_binary.o: In function `sk_refcnt_debug_release':
> include/net/sock.h:1025: multiple definition of `sk_refcnt_debug_release'
> kernel/sysctl.o:include/net/sock.h:1025: first defined here
> kernel/audit.o: In function `sk_refcnt_debug_release':
> include/net/sock.h:1025: multiple definition of `sk_refcnt_debug_release'
> kernel/sysctl.o:include/net/sock.h:1025: first defined here
> make[1]: *** [kernel/built-in.o] Error 1
> make: *** [kernel] Error 2
> 
> So we decide to make sk_refcnt_debug_release static to eliminate
> the error.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied and queued up for -stable, thanks.
