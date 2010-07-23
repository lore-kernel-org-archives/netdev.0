From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Add dsfield as alias for tos for ip rules
Date: Fri, 23 Jul 2010 13:22:28 -0700
Message-ID: <20100723132228.16394c0f@nehalam>
References: <1274451009-29456-1-git-send-email-hannemann@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46354 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab0GWUWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 16:22:31 -0400
In-Reply-To: <1274451009-29456-1-git-send-email-hannemann@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 May 2010 16:10:09 +0200
Arnd Hannemann <hannemann@nets.rwth-aachen.de> wrote:

> From: Arnd Hannemann <arnd@rhea.(none)>
> 
> Get ip rule parsing of "dsfield" in sync with ip route parsing and manual page.
> 
> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> ---
>  ip/iprule.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iprule.c b/ip/iprule.c
> index 7140375..cbf8226 100644
> --- a/ip/iprule.c
> +++ b/ip/iprule.c
> @@ -270,7 +270,8 @@ static int iprule_modify(int cmd, int argc, char **argv)
>  			if (get_u32(&pref, *argv, 0))
>  				invarg("preference value is invalid\n", *argv);
>  			addattr32(&req.n, sizeof(req), FRA_PRIORITY, pref);
> -		} else if (strcmp(*argv, "tos") == 0) {
> +		} else if (strcmp(*argv, "tos") == 0 ||
> +			   matches(*argv, "dsfield") == 0) {
>  			__u32 tos;
>  			NEXT_ARG();
>  			if (rtnl_dsfield_a2n(&tos, *argv))

Applied

-- 
