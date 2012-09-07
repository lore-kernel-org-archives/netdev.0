From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4/route: arg delay is useless in
 rt_cache_flush()
Date: Fri, 07 Sep 2012 17:24:39 +0200
Message-ID: <1347031479.2484.799.camel@edumazet-glaptop>
References: <1347013794.2484.488.camel@edumazet-glaptop>
	 <1347014729-28461-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52555 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab2IGPYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 11:24:43 -0400
Received: by eekc1 with SMTP id c1so1237313eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 08:24:42 -0700 (PDT)
In-Reply-To: <1347014729-28461-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 12:45 +0200, Nicolas Dichtel wrote:
> Since route cache deletion (89aef8921bfbac22f), delay is no
> more used. Remove it.
> 
> v2: remove ctl in ipv4_sysctl_rtcache_flush()
> 

Ideally, this v2:....: should be after the --- marker

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/net/route.h     |  2 +-
>  net/ipv4/arp.c          |  2 +-
>  net/ipv4/devinet.c      |  6 +++---
>  net/ipv4/fib_frontend.c | 20 ++++++++++----------
>  net/ipv4/fib_rules.c    |  2 +-
>  net/ipv4/fib_trie.c     |  6 +++---
>  net/ipv4/route.c        | 19 +++----------------
>  7 files changed, 22 insertions(+), 35 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
