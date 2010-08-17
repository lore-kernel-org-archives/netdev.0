From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH 10/16] drivers/net/wireless/wl12xx: Use available error
 codes
Date: Tue, 17 Aug 2010 08:42:21 +0300
Message-ID: <1282023741.1773.9.camel@powerslave>
References: <Pine.LNX.4.64.1008161827140.19313@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: ext Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:59136 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286Ab0HQFuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 01:50:10 -0400
In-Reply-To: <Pine.LNX.4.64.1008161827140.19313@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-16 at 18:27 +0200, ext Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Error codes are stored in ret, but the return value is always 0.  Return
> ret instead.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> local idexpression x;
> constant C;
> @@
> 
> if (...) { ...
>   x = -C
>   ... when != x
> (
>   return <+...x...+>;
> |
>   return NULL;
> |
>   return;
> |
> * return ...;
> )
> }
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---


This was indeed a bug.  Thanks!

Acked-by: Luciano Coelho <luciano.coelho@nokia.com>

-- 
Cheers,
Luca.

