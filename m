From: James Cameron <quozl@laptop.org>
Subject: Re: [PATCH] net: mark DECnet as broken
Date: Thu, 7 Apr 2016 17:50:17 +1000
Message-ID: <20160407075017.GI28117@us.netrek.org>
References: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.real-time.com ([63.170.91.9]:55600 "EHLO
	zimbra.real-time.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcDGHuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 03:50:24 -0400
Content-Disposition: inline
In-Reply-To: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 09:22:43AM +0200, Vegard Nossum wrote:
> There are NULL pointer dereference bugs in DECnet which can be triggered
> by unprivileged users and have been reported multiple times to LKML,
> however nobody seems confident enough in the proposed fixes to merge them
> and the consensus seems to be that nobody cares enough about DECnet to
> see it fixed anyway.
> 
> To shield unsuspecting users from the possible DOS, we should mark this
> BROKEN until somebody who actually uses this code can fix it.
> 
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> Link: https://lkml.org/lkml/2015/12/17/666
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: David Miller <davem@davemloft.net>

Reviewed-by: James Cameron <quozl@laptop.org>

(An old DECnet application programmer from way back, ah what fun!)

> ---
>  net/decnet/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/decnet/Kconfig b/net/decnet/Kconfig
> index f3393e1..b040172 100644
> --- a/net/decnet/Kconfig
> +++ b/net/decnet/Kconfig
> @@ -3,6 +3,7 @@
>  #
>  config DECNET
>  	tristate "DECnet Support"
> +	depends on BROKEN
>  	---help---
>  	  The DECnet networking protocol was used in many products made by
>  	  Digital (now Compaq).  It provides reliable stream and sequenced

fwiw, then Compaq merged into HP.

> -- 
> 1.9.1
> 

-- 
James Cameron
http://quozl.netrek.org/
