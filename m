From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: gre: correct calculation of max_headroom
Date: Sun, 29 Sep 2013 01:05:00 -0700
Message-ID: <1380441900.3596.13.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130929034050.GB8602@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46298 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3I2IFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 04:05:03 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so4246025pbc.25
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 01:05:02 -0700 (PDT)
In-Reply-To: <20130929034050.GB8602@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-29 at 05:40 +0200, Hannes Frederic Sowa wrote:
> gre_hlen already accounts for sizeof(struct ipv6_hdr) + gre header,
> so initialize max_headroom to zero. Otherwise the
> 
> 	if (encap_limit >= 0) {
> 		max_headroom += 8;
> 		mtu -= 8;
> 	}
> 
> increments an uninitialized variable before max_headroom was reset.
> 
> Found with coverity: 728539
> 
> Cc: Dmitry Kozlov <xeb@mail.ru>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
