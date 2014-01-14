From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCHv2 net-next 1/4] flowcache: Namespacify flowcache global
 parameters with xfrm
Date: Tue, 14 Jan 2014 19:53:29 +0100
Message-ID: <20140114185329.GA1971@kria>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
 <1389663588-29678-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:43041 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbaANSxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 13:53:50 -0500
Content-Disposition: inline
In-Reply-To: <1389663588-29678-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-14, 09:39:44 +0800, Fan Du wrote:
> Since flowcache is tightly coupled with IPsec, so it would be
> easier to put flow cache global parameters here into xfrm
> namespace part.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  include/net/netns/xfrm.h |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
> index 1006a26..52d0086 100644
> --- a/include/net/netns/xfrm.h
> +++ b/include/net/netns/xfrm.h
> @@ -6,6 +6,7 @@
>  #include <linux/workqueue.h>
>  #include <linux/xfrm.h>
>  #include <net/dst_ops.h>
> +#include <net/flowcache.h>

You are including a file that doesn't exist yet. You create it later,
with patch 2. This breaks bisection.

-- 
Sabrina
