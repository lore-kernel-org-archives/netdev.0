From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/2] ip: include libc headers first
Date: Tue, 30 May 2017 17:31:51 -0700
Message-ID: <20170530173151.771ea254@xeon-e3>
References: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34243 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdEaAby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:31:54 -0400
Received: by mail-pf0-f175.google.com with SMTP id 9so1758179pfj.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:31:54 -0700 (PDT)
In-Reply-To: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 May 2017 16:27:53 +0300
Baruch Siach <baruch@tkos.co.il> wrote:

> Including libc headers first helps as a workaround to redefinition of struct
> ethhdr with a suitably patched musl libc that suppresses the kernel
> if_ether.h.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
>  ip/iplink_bridge.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
> index 818b43c89b5b..cccdec1c203a 100644
> --- a/ip/iplink_bridge.c
> +++ b/ip/iplink_bridge.c
> @@ -13,9 +13,9 @@
>  #include <stdlib.h>
>  #include <string.h>
>  #include <netinet/in.h>
> +#include <netinet/ether.h>
>  #include <linux/if_link.h>
>  #include <linux/if_bridge.h>
> -#include <netinet/ether.h>
>  #include <net/if.h>
>  
>  #include "rt_names.h"

Applied.

Next time please fix the Subject line.  You implied two patches by using 1/2
but only one was sent.

It is easier for me if you include iproute2 in subject since then it goes into a
separate folder.

Subject: [PATCH iproute2] ip: include libc headers first

or if intended for net-next

Subject: [PATCH iproute2 net-next] ip: add magic VRF support
