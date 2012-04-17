From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv4:Remove two memleak reports by
 kmemeleak_not_leak.
Date: Tue, 17 Apr 2012 07:34:17 +0200
Message-ID: <1334640857.2472.7.camel@edumazet-glaptop>
References: <201204171333149372727@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: majianpeng <majianpeng@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54628 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab2DQFeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 01:34:20 -0400
Received: by wejx9 with SMTP id x9so3789162wej.19
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 22:34:18 -0700 (PDT)
In-Reply-To: <201204171333149372727@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 13:33 +0800, majianpeng wrote:
> From fe9ae7e12cc7bdc56705eb504facb71aa86dfe65 Mon Sep 17 00:00:00 2001
> From: majianpeng <majianpeng@gmail.com>
> Date: Tue, 17 Apr 2012 13:29:55 +0800
> Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.
> 
> 
> Signed-off-by: majianpeng <majianpeng@gmail.com>
> ---
>  net/ipv4/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 167ea10..dd15648 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -3505,6 +3505,6 @@ int __init ip_rt_init(void)
>   */
>  void __init ip_static_sysctl_init(void)
>  {
> -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +	kmemleak_not_leak(register_sysctl_paths(ipv4_path, ipv4_skeleton));
>  }
>  #endif

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks
