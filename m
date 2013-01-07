From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] xen/netfront: improve truesize tracking
Date: Mon, 07 Jan 2013 08:19:05 -0800
Message-ID: <1357575545.6919.3110.camel@edumazet-glaptop>
References: <1357572726-7059-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44967 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab3AGQTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:19:08 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so10775374pad.20
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 08:19:08 -0800 (PST)
In-Reply-To: <1357572726-7059-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 15:32 +0000, Ian Campbell wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>
