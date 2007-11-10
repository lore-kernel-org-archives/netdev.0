From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/01] iproute2-2.6.23: RFC4214 Support (3)
Date: Sat, 10 Nov 2007 02:04:43 +0100
Message-ID: <473503AB.7020402@trash.net>
References: <473371B3.5030908@yahoo.com> <4734FCEF.3080301@yahoo.com> <4734FE8D.5070107@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: osprey67 <osprey67@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38686 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762921AbXKJBE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 20:04:26 -0500
In-Reply-To: <4734FE8D.5070107@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

osprey67 wrote:
>
> --- iproute2-2.6.23/ip/iptunnel.c.orig  2007-11-08 16:27:24.000000000 
> -0800
> +++ iproute2-2.6.23/ip/iptunnel.c       2007-11-09 15:47:06.000000000 
> -0800
> @@ -1,3 +1,5 @@
> +#define ISATAP
> +
>  /*
>   * iptunnel.c         "ip tunnel"
>   *
> @@ -39,7 +41,12 @@ static void usage(void) __attribute__((n
>  static void usage(void)
>  {
>         fprintf(stderr, "Usage: ip tunnel { add | change | del | show 
> } [ NAME ]\n");
> +#if defined(ISATAP)
> +       fprintf(stderr, "          [ mode { ipip | gre | sit | isatap 
> } ]\n");
> +       fprintf(stderr, "          [ remote ADDR ] [ local ADDR ] [ 
> router ADDR ] [ lifetime NUMBER ]\n");
> +#else
>         fprintf(stderr, "          [ mode { ipip | gre | sit } ] [ 
> remote ADDR ] [ local ADDR ]\n");
> +#endif 


Why all the #ifdefs if you define it in the same file anyway?

