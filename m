From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sat, 12 Jan 2013 15:40:27 +0100
Message-ID: <50F175DB.5050400@gmail.com>
References: <50F17178.3090705@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:60130 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab3ALOkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:40:31 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so1263581eek.27
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 06:40:30 -0800 (PST)
In-Reply-To: <50F17178.3090705@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That looks good to me and is more or less exactly I wanted to do.


> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 3c53257..1de4e0c 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -52,6 +52,7 @@ enum {
>   #include <linux/hash.h>
>   
>   #include <net/neighbour.h>
> +#include <net/firewire.h>

-- snip --

> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 99cd286..9a0ba9c 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -72,6 +72,8 @@
>   #include <linux/netfilter.h>
>   #include <linux/netfilter_ipv6.h>
>   
> +#include <net/firewire.h>
-- snip --

But now we have to include firewire.h in the ndisc code.  The advantage
is that we the firewire_net structure is now private.

Regards,

Stephan
