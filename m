From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] xen/netfront: improve truesize tracking
Date: Mon, 07 Jan 2013 19:51:41 -0800 (PST)
Message-ID: <20130107.195141.2188454538235513522.davem@davemloft.net>
References: <1357572726-7059-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@eikelenboom.it,
	konrad.wilk@oracle.com, annie.li@oracle.com,
	xen-devel@lists.xen.org
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359Ab3AHDvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:51:42 -0500
In-Reply-To: <1357572726-7059-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 7 Jan 2013 15:32:06 +0000

> Using RX_COPY_THRESHOLD is incorrect if the SKB is actually smaller
> than that. We have already accounted for this in
> NETFRONT_SKB_CB(skb)->pull_to so use that instead.
> 
> Fixes WARN_ON from skb_try_coalesce.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: annie li <annie.li@oracle.com>
> Cc: xen-devel@lists.xen.org
> Cc: netdev@vger.kernel.org
> Cc: stable@kernel.org # 3.7.x only
> ---
> v2:
>  - acount frags as a full page as recommended by Eric.

Applied, thanks.
