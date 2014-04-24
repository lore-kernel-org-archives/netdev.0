From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: fib: fix fib dump restart
Date: Thu, 24 Apr 2014 07:18:04 -0700
Message-ID: <1398349084.29914.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53591645.7010609@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:63047 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbaDXOSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:18:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so1968373pad.35
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:18:06 -0700 (PDT)
In-Reply-To: <53591645.7010609@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-24 at 09:48 -0400, Chris Mason wrote:
> From: Kumar Sundararajan <kumar@fb.com>
> 
> When the ipv6 fib changes during a table dump, the walk is
> restarted and the number of nodes dumped are skipped. But the existing
> code doesn't advance to the next node after a node is skipped. This can
> cause the dump to loop or produce lots of duplicates when the fib
> is modified during the dump.
> 
> This change advances the walk to the next node if the current node is
> skipped after a restart.
> 
> Signed-off-by: Chris Mason <clm@fb.com>
> ---
>  net/ipv6/ip6_fib.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Hi Chris

Who wrote the patch exactly ?

If Kumar did, you need to put the
"Signed-off-by: Kumar Sundararajan <kumar@fb.com>" before your own
