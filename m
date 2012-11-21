From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3] xen/netfront: handle compound page fragments on
 transmit
Date: Wed, 21 Nov 2012 07:13:52 -0800
Message-ID: <1353510832.2590.39.camel@edumazet-glaptop>
References: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40185 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab2KUPN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 10:13:56 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so371882iea.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 07:13:55 -0800 (PST)
In-Reply-To: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 12:02 +0000, Ian Campbell wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in xennet_make_frags by iterating over the frames which
> make up the page.
> 
> This is the netfront equivalent to 6a8ed462f16b for netback.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: xen-devel@lists.xen.org
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> Cc: ANNIE LI <annie.li@oracle.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> Cc: Stefan Bader <stefan.bader@canonical.com>
> ---
> v3: limit to 80-characters. Use net_alert_ratelimited.
> v2: check we have enough room in the ring and that the other end can
>     cope with the number of slots in a single frame
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
