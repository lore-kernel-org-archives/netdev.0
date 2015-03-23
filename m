From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 v2] man ip-netns: Fix syntax in default ns
 process, indent's
Date: Mon, 23 Mar 2015 10:11:24 +0900
Message-ID: <20150323011120.GA20755@vergenet.net>
References: <1426960318-12044-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33672 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbCWBLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 21:11:34 -0400
Received: by pdnc3 with SMTP id c3so170683026pdn.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 18:11:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426960318-12044-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 07:51:58PM +0200, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
> v2:
>     Deleted leading spaces - suggested by Ben Hutchings <ben@decadent.org.uk>
> 
>  man/man8/ip-netns.8 | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
> index d496675..0c3dca8 100644
> --- a/man/man8/ip-netns.8
> +++ b/man/man8/ip-netns.8
> @@ -46,7 +46,7 @@ ip-netns \- process network namespace management
>  A network namespace is logically another copy of the network stack,
>  with its own routes, firewall rules, and network devices.
>  
> -By default process inherits network namespace from its parent. Initially all
> +By default a process inherits network namespace from its parent. Initially all

Perhaps also s/inherits/inherits its/

>  the processes share the same default network namespace from the init process.
>  
>  By convention a named network namespace is an object at
> @@ -103,10 +103,18 @@ option was specified then all the network namespace names will be removed.
>  It is possible to lose the physical device when it was moved to netns and
>  then this netns was deleted with a running process:
>  
> -    $ ip netns add net0
> -    $ ip link set dev eth0 netns net0
> -    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> -    $ ip netns del net0
> +.RS 10
> +$ ip netns add net0
> +.RE
> +.RS 10
> +$ ip link set dev eth0 netns net0
> +.RE
> +.RS 10
> +$ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> +.RE
> +.RS 10
> +$ ip netns del net0
> +.RE
>  
>  and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
>  will exit or will be killed. To prevent this the processes running in net0
> -- 
> 2.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
