From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: show metrics as an unsigned value
Date: Tue, 10 Apr 2012 08:48:57 -0700
Message-ID: <20120410084857.48f8397f@nehalam.linuxnetplumber.net>
References: <1334071226-17865-1-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52350 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759084Ab2DJPs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 11:48:59 -0400
In-Reply-To: <1334071226-17865-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Apr 2012 17:20:26 +0200
"Jorge Boncompte [DTI2]" <jorge@dti2.net> wrote:

> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> 
> Avoids showing negative metrics.
> 
> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
> ---
>  ip/iproute.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index c97f979..2d15c01 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -404,7 +404,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  				    abuf, sizeof(abuf)));
>  	}
>  	if (tb[RTA_PRIORITY])
> -		fprintf(fp, " metric %d ", *(__u32*)RTA_DATA(tb[RTA_PRIORITY]));
> +		fprintf(fp, " metric %u ", *(__u32*)RTA_DATA(tb[RTA_PRIORITY]));
>  	if (r->rtm_flags & RTNH_F_DEAD)
>  		fprintf(fp, "dead ");
>  	if (r->rtm_flags & RTNH_F_ONLINK)

Applied
