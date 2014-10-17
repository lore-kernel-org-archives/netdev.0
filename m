From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: dst_entry leak in ip_send_unicast_reply()
Date: Fri, 17 Oct 2014 09:56:29 -0700
Message-ID: <1413564989.24709.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <543E6762.9090807@parallels.com>
	 <20141017.115932.740288542547693461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vvs@parallels.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40856 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaJQQ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 12:56:32 -0400
Received: by mail-pa0-f48.google.com with SMTP id eu11so1152958pac.21
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 09:56:31 -0700 (PDT)
In-Reply-To: <20141017.115932.740288542547693461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 11:59 -0400, David Miller wrote:
> From: Vasily Averin <vvs@parallels.com>
> Date: Wed, 15 Oct 2014 16:24:02 +0400
> 
> > Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
> > 
> > ip_setup_cork() called inside ip_append_data() steals dst entry from rt to cork
> > and in case errors in __ip_append_data() nobody frees stolen dst entry
> > 
> > Signed-off-by: Vasily Averin <vvs@parallels.com>
> 
> Please, in the future, put the Fixes: tag first in the list of signoffs.
> 
> Eric, please review this change, it looks good to me.

It is good indeed, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
