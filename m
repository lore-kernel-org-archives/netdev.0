From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] ipneigh: update ip neigh usage
Date: Mon, 2 Dec 2013 23:51:01 -0800
Message-ID: <20131202235101.5b20f866@nehalam.linuxnetplumber.net>
References: <1385735860-7574-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:42794 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab3LCHvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 02:51:05 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so20548911pbc.39
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 23:51:04 -0800 (PST)
In-Reply-To: <1385735860-7574-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Nov 2013 22:37:40 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> From function nud_state_a2n we can see there are more states could be used. So
> update the ip neigh usage.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/ipneigh.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/ip/ipneigh.c b/ip/ipneigh.c
> index d76e035..c203775 100644
> --- a/ip/ipneigh.c
> +++ b/ip/ipneigh.c
> @@ -46,9 +46,12 @@ static void usage(void) __attribute__((noreturn));
>  static void usage(void)
>  {
>  	fprintf(stderr, "Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]\n"
> -		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
> -		        "          | proxy ADDR } [ dev DEV ]\n");
> +		        "                    [ nud STATE ] | proxy ADDR } [ dev DEV ]\n");
> +	fprintf(stderr, "\n");
>  	fprintf(stderr, "       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
> +	fprintf(stderr, "\n");
> +	fprintf(stderr, "STATE := { permanent | reachable | noarp | none | stale |\n");
> +	fprintf(stderr, "           incomplete | delay | probe | failed }\n");
>  	exit(-1);
>  }
>  

Accepted.
