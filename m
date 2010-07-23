From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: use int instead of long for RTAX_HOPLIMIT
 compare
Date: Fri, 23 Jul 2010 09:01:39 -0700
Message-ID: <20100723090139.346b6cca@nehalam>
References: <20100723133910.GC12942@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48372 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880Ab0GWQBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 12:01:42 -0400
In-Reply-To: <20100723133910.GC12942@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Jul 2010 15:39:10 +0200
Ulrich Weber <uweber@astaro.com> wrote:

> otherwise "if ((int)val == -1)" will never match on 64 bit systems
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>
> ---
>  ip/iproute.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 04b253a..711576e 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -494,7 +494,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  			val = *(unsigned*)RTA_DATA(mxrta[i]);
>  			switch (i) {
>  			case RTAX_HOPLIMIT:
> -				if ((long)val == -1)
> +				if ((int)val == -1)
>  					val = 0;
>  				/* fall through */
>  			default:

All applied

-- 
